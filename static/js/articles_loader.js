var ArticlesLoader = {
    "conf": {}
};

(function namespace() {

    // とりあえずは再利用など考えず, /user:{user_name}/articles ページのみで使うつもりで
    // 書いていく
    //
    // 将来的に変更の必要:
    // user_name, article_id は URI に含める際に
    // パーセントエンコードしないでよい文字のみで構成されるので, エンコードはしていない

    var createElem   = Helper.createElem;
    var convertLf2Br = Helper.convertLf2Br;

    /** 記事リストを表す ul 要素 */
    var article_list_elem = null;
    var getterButtonElem  = null;

    var _removeCallbackFunc = Helper.removeCallbackFunc;
    var _execEventListeners = Helper.execEventListeners;

    /**
     * ページに読み込みボタンを追加するなど, 初期処理を行う
     */
    ArticlesLoader.initialize = function initialize() {
        // リスト要素の取得
        articleListElem = document.getElementById( 'article-list' );
        this._listenersForLoadArticles = [];

        // 次ページの記事取得ボタン
        var getterFormElem = document.createElement( 'form' );
        var userName = ArticlesLoader.conf['user_name'];
        if ( "undefined" === typeof userName ) {
            throw new Error( "user_name not specified" );
        }

        getterFormElem.action = "/user:" + userName + "/articles";
        jQuery( getterFormElem ).submit( obtainNextArticles );
        var e = getterFormElem.appendChild( document.createElement( "input" ) );
        e.type  = "submit";
        e.value = "続きを読み込み";
        getterButtonElem = e;
        articleListElem.parentNode.insertBefore( getterFormElem, articleListElem.nextSibling );

        // 表示されている以上の記事がない場合
        var curPageNum = ArticlesLoader.conf['cur_page_num'];
        var numPages   = ArticlesLoader.conf['num_pages'   ];
        if ( curPageNum == numPages ) {
            e.value    = "続きはありません";
            e.disabled = true;
        }

        // ページャー削除
        jQuery( ".pager", document ).each( function callback( idx, e ) {
            e.parentNode.removeChild( e );
        } );
    };

    /**
     * タイマー終了時に呼び出されるリスナを追加する
     * 後で登録されたものが, タイマー終了時に先に呼び出される.
     * 既に登録したものを再度登録しようとした場合, 先のものは削除され, 
     * 後のものが登録される. (すなわち呼び出し順が変更される)
     */
    ArticlesLoader.addEventListenerForLoadArticles = function addEventListenerForLoadArticles( el ) {
        var ls = this._listenersForLoadArticles;
        // 多重登録しないように, 削除
        _removeCallbackFunc( ls, el );
        ls.push( el );
    };

    /**
     * タイマー終了時に呼び出されるリスナを削除する
     */
    ArticlesLoader.removeEventListenerForLoadArticles =
    function removeEventListenerForLoadArticles( el ) {
        var ls = this._listenersForLoadArticles;
        return ( _removeCallbackFunc( ls, callback ) !== null );
    };

    /**
     * 次のページの記事を取得する
     */
    var obtainNextArticles = function obtainNextArticles( evt ) {
        evt.preventDefault();

        getterButtonElem.disabled = true;
        var encdUserName = ArticlesLoader.conf['user_name'   ];
        var page         = ArticlesLoader.conf['cur_page_num'] + 1;
        var numPerPage   = ArticlesLoader.conf['num_per_page'];

        // リクエスト先 URI
        var apiUri = "/api/articles.json?" + "user_name="     + encdUserName +
                                              "&page="         + page         +
                                              "&num_per_page=" + numPerPage   ;
        // XMLHttpRequest を投げる
        jQuery.ajax({
            url     : apiUri,
            context : this,
            success : function onSuccess( data, textStat, req ) {
                reqCallbackSuccess( req, page )
            },
            error   : function onError( req, textStat, errorThrown ) {
                alert( "読み込み失敗 : " + req.responseText )
            },
            complete: function onComplete( req, textStat ) {
                if ( ArticlesLoader.conf['cur_page_num'] < ArticlesLoader.conf['num_pages'] ) {
                    getterButtonElem.disabled = false;
                } else {
                    getterButtonElem.value = "続きはありません";
                }
            }
        });
    };

    // 記事を表すための HTML 構築は別のところにまとめるべき
    var reqCallbackSuccess = function reqCallbackSuccess( req, page ) {
        // 例外補足すべきか
        var json = JSON.parse( req.responseText );
        // HTML に反映
        var i;
        var len = json.length;
        if ( len == 0 ) {
            alert( "これ以上の記事はありませんでした." );
        }
        for ( i = 0; i < len; ++ i ) {
            var title      = json[i]['title'     ];
            // TODO 日時の書式
            var created_on = json[i]['created_on'];
            var updated_on = json[i]['updated_on'];
            var uri        = json[i]['uri'       ];
            var body       = json[i]['body'      ];

            var articleElem
                = createElem( "article", null, [ [ "className", "article" ] ] );

            // タイトル
            var e  = articleElem.appendChild(
                    createElem( "h1", null , [ [ "className", "article-title" ] ] ) );
            e.appendChild( createElem( "a" , [ title ],
                        [ [ "href", uri ], [ "className", "article-uri" ] ]  ) );

            // 本文
            var createArticleBodyElem = function createArticleBodyElem( bodyText ) {
                return createElem( "div", convertLf2Br( bodyText ), 
                                   [ [ "className", "article-body" ] ] );
            };
            articleElem.appendChild( createArticleBodyElem( body ) );

            // 日時
            var createArticleDateElem = function createArticleDateElem( created_on, updated_on ) {
                var e = createElem( "div", null, [ [ "className", "article-date" ] ] );
                e.appendChild( createElem( "div", [ created_on ],
                            [ [ "className", "article-date-created_on" ] ] ) );
                e.appendChild( createElem( "div", [ updated_on ],
                            [ [ "className", "article-date-updated_on" ] ] ) );
                return e;
            };
            articleElem.appendChild( createArticleDateElem( created_on, updated_on ) );

            articleListElem.appendChild( articleElem );
        }
        ArticlesLoader.conf['cur_page_num'] = page;

        // イベントリスナを実行
        _execEventListeners( ArticlesLoader._listenersForLoadArticles );
    }

})();
