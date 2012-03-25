/* その場編集機能のための JavaScript */

/**
 * ArticleEditor オブジェクトの管理を行うオブジェクトのコンストラクタ
 */
var ArticleEditorManager;

(function namespace() {

    // Helper から関数読み込み
    var createElem   = Helper.createElem;
    var convertLf2Br = Helper.convertLf2Br;
    var createArticleChildNodesFromJson = Helper.createArticleChildNodesFromJson;

    //============================
    // class ArticleEditorManager 
    //============================

    // ArticleEditor のための状態を表す定数
    /** 通常表示中 */
    var ST_SHOWING = { name : "show" };
    /** 編集のための生のテキストデータの要求中 (レスポンス待ち) */
    var ST_REQUESTING_RAW_TEXT = { name : "request raw text" };
    /** 編集画面表示中 */
    var ST_EDITING = { name : "edit" };
    /** 編集したテキストの送信中 (レスポンス待ち) */
    var ST_SUBMITTING = { name : "submit" };

    /**
     * 各記事毎に生成される記事編集用オブジェクトのコンストラクタ
     */
    var ArticleEditor = function ArticleEditor( articleElem ) {
        if ( "undefined" !== typeof articleElem.__diary_articleEditor ) {
            throw new Error( "already bound to another ArticleEditor object" );
        }

        this.articleElem    = articleElem;
        this.currentStatus  = ST_SHOWING;
        this.currentRequest = null;

        // user_name と article_id の取得
        var userName, articleId;
        var elemArticleUri = jQuery( ".article-uri", articleElem );
        if ( elemArticleUri.length !== 1 ) {
            throw new Error( "invalid article element" );
        }
        elemArticleUri = elemArticleUri[0];
        var articleUri = elemArticleUri.href;
        pathComps = articleUri.split( "/" );
        var i, len;
        len = pathComps.length;
        for( i = 0; i < len; ++ i ) {
            var comp = pathComps[i];
            var pair = comp.split( ":", 2 );
            if ( pair.length == 2 ) {
                if ( pair[0] == "user" ) {
                    userName = pair[1];
                }
                else if ( pair[0] == "article" ) {
                    articleId = pair[1];
                }
            }
        }
        if ( "undefined" === ( typeof userName ) || "undefined" === ( typeof articleId ) ) {
            throw new Error( "invalid article element" );
        }

        this.articleInfo = {
            article_id  : articleId,
            user_name   : userName,
            uri         : elemArticleUri
        };

        this.insertEditRequestForm();

        // 要素にこのオブジェクトを結びつける
        articleElem.__diary_articleEditor = this;
    };

    // 編集ボタンの追加
    ArticleEditor.prototype.insertEditRequestForm = function insertEditRequestForm() {
        var ae = this.articleElem;
        var abes = jQuery( ".article-body", ae );
        if ( abes.length !== 1 ) {
            throw new Error( "invalid article element" );
        }
        if ( abes.length > 0 ) {
            var uri = this.articleInfo["uri"];
            var abe = abes[0];
            var ame = this.createEditRequestForm();
            abe.parentNode.insertBefore( ame, abe );
        }
    };

    // 編集ボタンの生成
    ArticleEditor.prototype.createEditRequestForm = function createEditRequestForm() {
        var uri = this.articleInfo["uri"];
        var e;
        e = createElem( "input", null , [ [ "type", "submit" ], [ "value", "編集" ] ] );
        e = createElem( "form" , [ e ], [ [ "method", "GET"  ], [ "action", uri + ";edit" ] ] );
        e.__diary_articleEditor = this;
        jQuery( e ).submit( _el_requestEditing );
        e = createElem( "div"  , [ e ], [ [ "className", "article-manager" ] ] );
        return e;
    };

    // --------------------
    //  画面変更用メソッド 
    // --------------------

    var removeAllChildNodes = function removeAllChildNodes( elem ) {
        while ( elem.lastChild ) {
            elem.removeChild( elem.lastChild );
        }
    };

    ArticleEditor.prototype.showNormalView = function showNormalView( articleInfo ) {
        var articleElem = this.articleElem;

        var e = createArticleChildNodesFromJson( articleInfo );
        removeAllChildNodes( articleElem );
        articleElem.appendChild( e );
        this.insertEditRequestForm();
    };

    ArticleEditor.prototype.showEditView = function showEditView( articleInfo ) {
        var articleElem = this.articleElem;
        removeAllChildNodes( articleElem );
        // articleInfo のプロパティ : body,created_on,title,id,uri,updated_on

        var ae = this.articleElem;

        var title     = articleInfo["title"];
        var createdOn = new Date( articleInfo["created_on_epoch"] * 1000 );
        var updatedOn = new Date( articleInfo["updated_on_epoch"] * 1000 );
        // update 先 URI?
        var userName  = this.articleInfo["user_name"];
        var articleId = this.articleInfo["article_id"];
        var uri       = "/user:" + userName + "/article:" + articleId + ";update";
        var body      = articleInfo["body"];

        var e = createElem( "form", null, [ [ "action", uri ], [ "method", "POST" ] ] );
        jQuery( e ).submit( _el_startUpdating );
        e.__diary_articleEditor = this;
        var editableArticleElem = document.createDocumentFragment();
        editableArticleElem.appendChild( e );

        // タイトル
        var createEArticleTitleElem = function createEArticleTitleElem( title, uri ) {
            var e = createElem( "input", null, [ [ "value", title ], [ "name", "title" ] ] );
            return createElem( "h1", [ e ], [ [ "className", "article-title" ] ] );
        };
        e.appendChild( createEArticleTitleElem( title, uri ) );

        // フォームマネージャ
        var createEArticleManagerElem = function createEArticleManagerElem() {
            var e = createElem( "input", null, [ [ "type", "submit" ], [ "value", "送信" ] ] );
            return createElem( "div", [ e ], [ [ "className", "article-manager" ] ] );
        };
        e.appendChild( createEArticleManagerElem() );

        // 本文
        var createEArticleBodyElem = function createEArticleBodyElem( bodyText ) {
            var e = createElem( "textarea", [ bodyText ], [ [ "name", "body" ] ] );
            return createElem( "div", [ e ], [ [ "className", "article-body" ] ] );
        };
        e.appendChild( createEArticleBodyElem( body ) );

        // 日時
        e.appendChild( Helper.createArticleDateElem( createdOn, updatedOn ) );

        var pe = ae.parentNode;
        ae.appendChild( editableArticleElem );
    };

    ArticleEditor.prototype.showWaitingViewForRawDataRequest = 
    function showWaitingViewForRawDataRequest() {
        var articleElem = this.articleElem;
        removeAllChildNodes( articleElem );
        articleElem.appendChild( document.createElement( "p" ) ).
            appendChild( document.createTextNode( "Now loading..." ) );
    };

    ArticleEditor.prototype.showWaitingViewForSubmit = function showWaitingViewForSubmit() {
        var articleElem = this.articleElem;
        removeAllChildNodes( articleElem );
        articleElem.appendChild( document.createElement( "p" ) ).
            appendChild( document.createTextNode( "Now submitting..." ) );
    };

    // ----------------------------
    //  article 内部の Save / Load 
    // ----------------------------

    var saveView = function saveView( articleElem ) {
        var ee = [];
        var e  = articleElem.firstChild;
        while ( e ) {
            ee.push( e );
            e = e.nextSibling;
        }
        return ee;
    };

    ArticleEditor.prototype.saveLastNormalView = function saveLastNormalView() {
        this.lastNormalViewElems = saveView( this.articleElem );
    };

    ArticleEditor.prototype.saveLastEditView = function saveLastEditView() {
        this.lastEditViewElems = saveView( this.articleElem );
    };

    var loadView = function loadView( articleElem, elems ) {
        if ( "undefined" === typeof elems ) {
            throw new Error();
        }
        var e = document.createDocumentFragment();
        var i, len;
        len = elems.length;
        for ( i = 0; i < len; ++ i ) {
            e.appendChild( elems[i] );
        }
        removeAllChildNodes( articleElem );
        articleElem.appendChild( e );
    };

    ArticleEditor.prototype.loadLastNormalView = function loadLastNormalView() {
        loadView( this.articleElem, this.lastNormalViewElems );
    };

    ArticleEditor.prototype.loadLastEditView = function loadLastEditView() {
        loadView( this.articleElem, this.lastEditViewElems );
    };

    // ----------------
    //  イベントリスナ 
    // ----------------

    var _el_requestEditing = function _el_requestEditing( evt ) {
        var editor = evt.currentTarget.__diary_articleEditor;
        editor.requestEditing();
        evt.preventDefault();
    };

    ArticleEditor.prototype.requestEditing = function requestEditing() {
        var userName  = this.articleInfo["user_name"];
        var articleId = this.articleInfo["article_id"];
        // 最後の通常状態として保存
        this.saveLastNormalView();
        // フォームを読み込み状態にする
        this.showWaitingViewForRawDataRequest();
        // XMLHttpRequest を投げる
        jQuery.ajax({
            url     : "/api/article.json?user_name=" + userName + "&article_id=" + articleId,
            context : this,
            success : _el_success_requestEditing,
            error   : _el_fail_requestEditing
        });
    };

    /** 編集内容のリクエストに成功した場合
     * this をコンテキストにして呼び出される
     */
    var _el_success_requestEditing = function _el_success_requestEditing( data, textStat, req ) {
        // 状態遷移
        this.currentStatus = ST_EDITING;
        this.showEditView( data );
    };

    /**
     * 編集内容のリクエストに失敗した場合
     * this をコンテキストにして呼び出される
     */
    var _el_fail_requestEditing = function _el_fail_requestEditing( req, textStat, errorThrown ) {
        alert( "編集用データの取得に失敗しました\n" +
               "  status code   : " + req.status +
               "  response text : " + req.responseText + ")" );
        // 状態遷移
        this.currentStatus = ST_SHOWING;
        this.loadLastNormalView();
    };

    var _el_startUpdating = function _el_startUpdating( evt ) {
        var formElem = evt.currentTarget;
        var articleEditor = formElem.parentNode.__diary_articleEditor;
        articleEditor.startUpdating( formElem );
        evt.preventDefault();
    };

    ArticleEditor.prototype.startUpdating = function startUpdating( formElem ) {
        var userName  = this.articleInfo["user_name"];
        var articleId = this.articleInfo["article_id"];
        var uri = "/api/article.json;update";
        var i;
        var len = formElem.elements.length;
        var ss = "";
        var params = [];
        for ( i = 0; i < len; ++ i ) {
            var e = formElem.elements[i];
            if ( "string" === ( typeof e.name ) && e.name !== "" ) {
                params.push( { name: e.name, value: e.value } );
            }
        }
        jQuery.ajax({
            type    : "POST",
            url     : "/api/article.json;update?user_name=" + userName + "&article_id=" + articleId,
            data    : params,
            context : this,
            success : _el_success_updating,
            error   : _el_fail_updating
        });

        // 状態遷移
        this.saveLastEditView();
        this.currentState = ST_SUBMITTING;
        this.showWaitingViewForSubmit(); 
    }

    var _el_success_updating = function _el_success_updating( data, textStat, req ) {
        // 状態遷移
        this.currentState = ST_SHOWING;
        this.showNormalView( data );
    };

    var _el_fail_updating = function _el_fail_updating( req, textStat, errorThrown ) {
        alert( "更新に失敗しました\n" +
               "  " + req.responseText );

        // 状態遷移
        this.currentState = ST_EDITING;
        this.loadLastEditView();
    };


    //============================
    // class ArticleEditorManager 
    //============================

    ArticleEditorManager = function ArticleEditorManager( selector ) {
        if ( "undefined" === typeof selector ) selector = ".article";
        this._articleEditors = [];
        this._targetSelector = selector;
    };
    ArticleEditorManager.prototype.initialize = function initialize() {
        var ee = this._articleEditors;
        jQuery( this._targetSelector, document ).each( function tmp( idx, e ) {
            ee.push( new ArticleEditor( e ) );
        } );
    };
    ArticleEditorManager.prototype.update = function update() {
        var ee = this._articleEditors;
        jQuery( this._targetSelector, document ).each( function tmp( idx, e ) {
            if ( "undefined" === typeof e.__diary_articleEditor ) {
                ee.push( new ArticleEditor( e ) );
            }
        } );
    };
})();
