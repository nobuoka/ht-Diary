/* その場編集機能のための JavaScript */

/**
 * ArticleEditor オブジェクトの管理を行うオブジェクトのコンストラクタ
 */
var ArticleEditorManager = null;

(function namespace() {
    /**
     * 各記事毎に生成される記事編集用オブジェクトのコンストラクタ
     */
    var ArticleEditor = null;

    /**
     * memo:
     * ArticleEditor は各 article 要素に結びつけられる
     * article 要素は表示用のものと編集用のもので別に生成
     * すなわち, 
     *   [HTMLElement article (表示用)] <-> [ArticleEditor object] <-> [HTMLElement article (編集用)]
     * というような関係で参照しあう
     *
     * ArticleEditor の仕事
     *   - 待機状態の表示
     *   - 編集フォームの表示
     *   - 閲覧用要素の表示
     *   - 編集内容の送信
     *   - 状態遷移機能?
     *
     * 状態?
     *   - 通常表示中
     *   - 編集表示中
     *   - 編集表示用データダウンロード中
     *   - 更新リクエストのレスポンス待機中
     */

    // ArticleEditor のための状態を表す定数
    /** 通常表示中 */
    var ST_SHOWING = { name : "show" };
    /** 編集のための生のテキストデータの要求中 (レスポンス待ち) */
    var ST_REQUESTING_RAW_TEXT = { name : "request raw text" };
    /** 編集画面表示中 */
    var ST_EDITING = { name : "edit" };
    /** 編集したテキストの送信中 (レスポンス待ち) */
    var ST_SUBMITTING = { name : "submit" };

    ArticleEditor = function ArticleEditor( articleElem ) {
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
        };

        // 編集ボタンの追加
        var elemArticleBody = jQuery( ".article-body", articleElem );
        if ( elemArticleBody.length !== 1 ) {
            throw new Error( "invalid article element : " + elemArticleBody.length );
        }
        elemArticleBody = elemArticleBody[0];
        var articleBody = elemArticleBody.text;

        this.initialize();

        // 要素にこのオブジェクトを結びつける
        articleElem.__diary_articleEditor = this;
    };

    ArticleEditor.prototype.initialize = function initialize() {
        var ae = this.articleElem;
        var aaes = ae.getElementsByClassName( "article-uri" );
        var abes = ae.getElementsByClassName( "article-body" );
        if ( abes.length > 0 && aaes.length > 0 ) {
            var aae = aaes.item( 0 );
            var uri = aae.href;
            var abe = abes.item( 0 );
            var ame = createElem( "div", null, [ [ "className", "article-manager" ] ] );
            var amfe = ame.appendChild( createElem( "form", null, 
                            [ [ "method", "GET" ], [ "action", uri + ";edit" ] ] ) );
            amfe.appendChild( createElem( "input", null, 
                            [ [ "type", "submit" ], [ "value", "編集" ] ] ) );
            abe.parentNode.insertBefore( ame, abe );

            this.articleElem = ae;
            ae.__diary_articleEditor = this;
            amfe.__diary_articleElem = ae;
            amfe.__diary_articleEditor = this;
            amfe.addEventListener( "submit", _el_requestEditing, false );
        }
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

        var title     = articleInfo["title"];
        var createdOn = articleInfo["created_on"];
        var updatedOn = articleInfo["updated_on"];
        // update 先 URI?
        var userName  = this.articleInfo["user_name"];
        var articleId = this.articleInfo["article_id"];
        // TODO : uri encoding
        var uri       = "/user:" + userName + "/article:" + articleId + ";update";
        var body      = articleInfo["body"];

        var e = document.createDocumentFragment();

        // タイトル
        var createEArticleTitleElem = function createEArticleTitleElem( title, uri ) {
            var e = createElem( "span", [ title ] );
            return createElem( "h1", [ e ], [ [ "className", "article-title" ] ] );
        };
        e.appendChild( createEArticleTitleElem( title, uri ) );

        // TODO 必要なものに変更
        // フォームマネージャ
        var createEArticleManagerElem = function createEArticleManagerElem() {
            var e = createElem( "input", null, [ [ "type", "submit" ], [ "value", "送信" ] ] );
            return createElem( "div", [ e ], [ [ "className", "article-manager" ] ] );
        };
        e.appendChild( createEArticleManagerElem() );

        // 本文
        var createEArticleBodyElem = function createEArticleBodyElem( bodyText ) {
            return createElem( "div", convertLf2Br( bodyText ), [ [ "className", "article-body" ] ] );
        };
        e.appendChild( createEArticleBodyElem( body ) );

        // 日時
        var createEArticleDateElem = function createEArticleDateElem( createdOn, updatedOn ) {
            var e1 = createElem( "div", [ createdOn ], 
                                 [ [ "className", "article-date-created_on" ] ] );
            var e2 = createElem( "div", [ updatedOn ], 
                                 [ [ "className", "article-date-updated_on" ] ] );
            return createElem( "div", [ e1, e2 ], [ [ "className", "article-date" ] ] );
        };
        e.appendChild( createEArticleDateElem( createdOn, updatedOn ) );

        removeAllChildNodes( articleElem );
        articleElem.appendChild( e );
    };

    ArticleEditor.prototype.showEditView = function showEditView( articleInfo ) {
        var articleElem = this.articleElem;
        removeAllChildNodes( articleElem );
        // articleInfo のプロパティ : body,created_on,title,id,uri,updated_on

        var ae = this.articleElem;

        var title     = articleInfo["title"];
        var createdOn = articleInfo["created_on"];
        var updatedOn = articleInfo["updated_on"];
        // update 先 URI?
        var userName  = this.articleInfo["user_name"];
        var articleId = this.articleInfo["article_id"];
        // TODO : uri encoding
        var uri       = "/user:" + userName + "/article:" + articleId + ";update";
        var body      = articleInfo["body"];

        var e = createElem( "form", null, [ [ "action", uri ], [ "method", "POST" ] ] );
        e.addEventListener( "submit", _el_startUpdating, false );
        e.__diary_articleEditor = this;
        var editableArticleElem = document.createDocumentFragment();
        editableArticleElem.appendChild( e );
            //createElem( "article", [ e ], [ [ "className", "article" ] ] );

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
        var createEArticleDateElem = function createEArticleDateElem( createdOn, updatedOn ) {
            var e1 = createElem( "div", [ createdOn ], 
                                 [ [ "className", "article-date-created_on" ] ] );
            var e2 = createElem( "div", [ updatedOn ], 
                                 [ [ "className", "article-date-updated_on" ] ] );
            return createElem( "div", [ e1, e2 ], [ [ "className", "article-date" ] ] );
        };
        e.appendChild( createEArticleDateElem( createdOn, updatedOn ) );

        var pe = ae.parentNode;
        ae.appendChild( editableArticleElem );
        //alert( ae + " : " + editableArticleElem );
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
        evt.preventDefault(); // TODO for IE
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
            // TODO : URI のエンコーディング
            url     : "/api/article.json?user_name=" + userName + "&article_id=" + articleId,
            context : this,
            success : _el_success_requestEditing, //function ( data, dataType ) { },
            error   : _el_fail_requestEditing // function ( req, textStatus, errorThrown ) {}
        });
    };

    /** 編集内容のリクエストに成功した場合
     * this をコンテキストにして呼び出される
     */
    var _el_success_requestEditing = function _el_success_requestEditing( data, dataType ) {
        // 状態遷移
        this.currentStatus = ST_EDITING;
        this.showEditView( data );
    };

    /**
     * 編集内容のリクエストに失敗した場合
     * this をコンテキストにして呼び出される
     */
    var _el_fail_requestEditing = function _el_fail_requestEditing( req, textStatus, errorThrown ) {
        // alert を表示
        // TODO : もっと詳しいエラー情報の表示 (HTTP ステータスコードとか)
        //alert( this.constructor + " : " + req.status + " : " + textStatus );
        alert( "編集用データの取得に失敗しました\n" +
               "  status code   : " + req.status +
               "  response text : " + req.responseText + ")" );
        // 状態遷移
        this.currentStatus = ST_SHOWING;
        this.loadLastNormalView();
    };

    /*
    // req が成功したらこっちに
    ArticleEditor.prototype.startEditing = function startEditing() {
        var ae = this.articleElem; // TODO for IE

        // TODO 値の取得
        var title      = 'tst';
        var created_on = 'tst';
        var updated_on = 'test';
        // update 先 URI
        var uri        = 'test';
        var body       = 'テストだよ';

        var e = createElem( "form", null, [ [ "action", uri ], [ "method", "POST" ] ] );
        e.addEventListener( "submit", _el_startUpdating, false );
        e.__diary_articleEditor = this;
        var editableArticleElem
            = createElem( "article", [ e ], [ [ "className", "article" ] ] );

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
        var createEArticleDateElem = function createEArticleDateElem( created_on, updated_on ) {
            var e1 = createElem( "div", [ created_on ], 
                                 [ [ "className", "article-date-created_on" ] ] );
            var e2 = createElem( "div", [ updated_on ], 
                                 [ [ "className", "article-date-updated_on" ] ] );
            return createElem( "div", [ e1, e2 ], [ [ "className", "article-date" ] ] );
        };
        e.appendChild( createEArticleDateElem( created_on, updated_on ) );

        var pe = ae.parentNode;
        //alert( ae + " : " + editableArticleElem );
        pe.insertBefore( editableArticleElem, ae );
        pe.removeChild( ae );
    }
    */

    var _el_startUpdating = function _el_startEditing( evt ) {
        var formElem = evt.currentTarget;
        var articleEditor = formElem.parentNode.__diary_articleEditor;
        articleEditor.startUpdating( formElem );
        evt.preventDefault(); // TODO for IE
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
                /* TODO 削除する
                var pp = params[e.name];
                if ( "undefined" === typeof pp ) {
                    pp = params[e.name] = [];
                }
                pp.push( e.value );
                */
                params.push( { name: e.name, value: e.value } );
            }
        }
        jQuery.ajax({
            type    : "POST",
            // TODO : URI のエンコーディング
            url     : "/api/article.json;update?user_name=" + userName + "&article_id=" + articleId,
            data    : params,
            context : this,
            success : _el_success_submitting,
            error   : _el_fail_submitting
        });

        // 状態遷移
        this.saveLastEditView();
        this.currentState = ST_SUBMITTING;
        this.showWaitingViewForSubmit(); 
    }

    var _el_success_submitting = function _el_success_submitting( data, dataType ) {
        // 状態遷移
        this.currentState = ST_SHOWING;
        this.showNormalView( data );
    };

    var _el_fail_submitting = function _el_fail_submitting( req, textStatus, errorThrown ) {
        alert( "更新に失敗しました\n" +
               "  " + req.responseText );

        // 状態遷移
        this.currentState = ST_EDITING;
        this.loadLastEditView();
    };


    ArticleEditorManager = function ArticleEditorManager() {
        this._articleEditors = [];
    };
    ArticleEditorManager.prototype.initialize = function initialize() {
        // TODO for IE
        var articleElems = document.getElementsByClassName( "article" );
        var i;
        var len = articleElems.length;
        for ( i = 0; i < len; ++ i ) {
            var e  = articleElems[i];
            var ae = new ArticleEditor( e );
            this._articleEditors.push( ae );
        }
    };
})();
