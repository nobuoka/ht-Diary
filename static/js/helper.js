var Helper = {};

(function namespace() {
    /**
     * HTML DOM Element を生成するためのユーティリティメソッド
     * @param tagname 生成する要素の名前
     * @param children 生成した要素に子要素として append するノードまたは文字列の配列. 
     *          文字列の場合は自動的に TextNode にされる
     * @param attrs 生成した要素に付加する属性の配列. [ [ attr_name, attr_value ], ... ] の形式
     */
    Helper.createElem = function createElem( tagname, children, attrs ) {
        var e = document.createElement( tagname );
        if ( ! children ) {
            // do nothig
        }
        else if ( Array.isArray( children ) ) {
            var c;
            var i = 0;
            var len = children.length;
            for ( i = 0; i < len; ++ i ) {
                c = children[i];
                if ( "string" === typeof c )
                    c = document.createTextNode( c );
                e.appendChild( c );
            }
        }
        else {
            throw new Error( "invalid argument : " + children );
        }
        if ( attrs ) {
            var i = 0;
            var len = attrs.length;
            for ( i = 0; i < len; ++ i ) {
                e[ attrs[i][0] ] = attrs[i][1];
            }
        }
        return e;
    };

    /**
     * 文字列の改行を HTMLBRElement に変更する
     * 文字列と br 要素からなる配列を返す.
     */
    Helper.convertLf2Br = function convertLf2Br( str ) {
        var i;
        var ee = [];
        var lines = str.split( "\n" );
        var len = lines.length;
        for ( i = 0; i < len; ++ i ) {
            if ( i !== 0 )
                ee.push( document.createElement( "br" ) );
            ee.push( lines[i] );
        }
        return ee;
    };

    /**
     * リスナの配列の中から, 指定の関数があるか探し, あればその要素を削除する
     * 要素を削除した場合, その要素を返す. 削除しなかった場合, null を返す
     */
    Helper.removeCallbackFunc = function removeCallbackFunc( ls, func ) {
        var i;
        var len = ls.length;
        for ( i = 0; i < len; ++ i ) {
            if ( ls[i] === func ) {
                break;
            }
        }
        // 見つかった場合は削除
        var e = null;
        if ( i < len ) {
            e = ls.splice( i, 1 )[0];
        }
        return e;
    };

    Helper.execEventListeners = function execEventListeners( ls ) {
        var i = ls.length;
        while ( i ) {
            -- i;
            try {
                ls[i]();
            } catch ( err ) {
                // リスナ内でエラーが発生しても, 別のリスナが実行されるように例外補足
                // do nothing
            }
        }
    };
})();
