var createElem = function createElem( tagname, children, attrs ) {
    var e = document.createElement( tagname );
    // TODO
    if ( children === null ) {
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
    // TODO
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
 * 文字列の改行を HTML br element に変更する
 * 文字列と br 要素からなる配列を返す.
 */
var convertLf2Br = function convertLf2Br( str ) {
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
