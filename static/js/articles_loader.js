var ArticlesLoader = {
    "conf": {}
};

(function namespace() {

    // とりあえずは再利用など考えず, /user:{user_name}/articles ページのみで使うつもりで
    // 書いていく

    /** 記事リストを表す ul 要素 */
    var article_list_elem = null;
    var getterButtonElem  = null;

    /**
     * ページに読み込みボタンを追加するなど, 初期処理を行う
     */
    ArticlesLoader.initialize = function initialize() {
        // リスト要素の取得
        articleListElem = document.getElementById( 'article-list' );

        // TODO 次ページの記事取得ボタン
        var getterFormElem = document.createElement( 'form' );
        var userName = ArticlesLoader.conf['user_name'];
        // TODO userName が undefined の場合, 例外送出
        // TODO userName をエンコード (URI の中に入れられるように)
        getterFormElem.action = "/user:" + userName + "/articles";
        getterFormElem.addEventListener( "submit", obtainNextArticles, false );
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

        // ページャーの取得 (最後に削除する); TODO for IE
        pagerElems = document.getElementsByClassName( 'pager' );
        var i;
        for ( i = pagerElems.length - 1; 0 <= i; -- i ) {
            var e = pagerElems.item( i );
            e.parentNode.removeChild( e );
        }
    };

    /**
     * 次のページの記事を取得する
     */
    var obtainNextArticles = function( evt ) {
        evt.preventDefault(); // TODO for IE

        getterButtonElem.disabled = true;
        var encdUserName = ArticlesLoader.conf['user_name'   ]; // TODO エンコード
        var page         = ArticlesLoader.conf['cur_page_num'] + 1; // TODO ページ番号インクリメント
        var numPerPage   = ArticlesLoader.conf['num_per_page'];

        // リクエスト先 URI
        var api_uri = "/api/articles.json?" + "user_name="     + encdUserName +
                                              "&page="         + page         +
                                              "&num_per_page=" + numPerPage   ;
        // TODO for IE
        var req = new XMLHttpRequest();
        req.open( "GET", api_uri, true );
        req.onreadystatechange = function onreadystatechange( evt ) {
            // TODO 例外補足
            if ( req.readyState == 4 ) {
                if ( req.status == 200 ) {
                    var json = JSON.parse( req.responseText );
                    // HTML に反映
                    var i;
                    var len = json.length;
                    if ( len == 0 ) {
                        alert( "これ以上の記事はありませんでした." );
                        // TODO これ以上記事がないなら, ボタンを "すべての記事が表示されています" にする
                    }
                    for ( i = 0; i < len; ++ i ) {
                        var title      = json[i]['title'     ];
                        // TODO 日時の書式
                        var created_on = json[i]['created_on'];
                        var updated_on = json[i]['updated_on'];
                        var uri        = json[i]['uri'       ];
                        var body       = json[i]['body'      ];

                        var createElem = function createElem( tagname, text, attrs ) {
                            var e = document.createElement( tagname );
                            // TODO
                            if ( text ) {
                                e.appendChild( document.createTextNode( text ) );
                            }
                            // TODO
                            if ( attrs ) {
                                var i = 0;
                                var len = attrs.length;
                                for ( i = 0; i < len; ++ i ) {
                                    e[ attrs[i][0] ] = attrs[i][1];
                                }
                            }
                            return e;
                        }
                        var articleElem
                            = createElem( "article", null, [ [ "className", "article" ] ] );

                        // タイトル
                        var e  = articleElem.appendChild(
                                createElem( "h1", null , [ [ "className", "article-title" ] ] ) );
                        e.appendChild( createElem( "a" , title, [ [ "href", uri ] ]  ) );
                        // 本文
                        articleElem.appendChild(
                                createElem( "div", body, [ [ "className", "article-body" ] ] ) );
                        // 日時
                        var e = articleElem.appendChild(
                                createElem( "div", null, [ [ "className", "article-date" ] ] ) );
                        e.appendChild( createElem( "div", created_on,
                                             [ [ "className", "article-date-created_on" ] ] ) );
                        e.appendChild( createElem( "div", updated_on,
                                             [ [ "className", "article-date-updated_on" ] ] ) );
                        articleElem.appendChild( e );

                        articleListElem.appendChild( articleElem );
                    }
                    ArticlesLoader.conf['cur_page_num'] = page;
                } else {
                    // TODO 失敗
                    alert( "失敗: " + req.responseText );
                }
                if ( ArticlesLoader.conf['cur_page_num'] < ArticlesLoader.conf['num_pages'] ) {
                    getterButtonElem.disabled = false;
                } else {
                    getterButtonElem.value = "続きはありません";
                }
            }
        };
        req.send();

    };

})();
