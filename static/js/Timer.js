/**
 * タイマーを管理するタイマークラス
 */
var Timer;

(function namespace() {
    /**
     * コンストラクタ
     * @arg time タイマーの時間: 単位は ms
     */
    Timer = function Timer( time ) {
        if ( ! ( this instanceof Timer ) ) {
            throw new Error( "Timer constructor can't be called as function" );
        }
        /** 残り時間: 最初は指定された値で, stop, start を繰り返すと減っていく;
         *            タイマー終了後は null */
        this.remTime   = time; // [ms]
        /** タイマー終了時に呼び出される関数たち */
        this.listeners = [];
        /** setTimeout の返り値; setTimeout でカウントダウンしていないときは null にすること */
        this.timerId   = null;
        /** 実行中の setTimeout のカウントダウンを開始した時刻; 
         * stop したときに rest_time を計算するために使う */
        this.startTime = null; // [ms]
    };

    /**
     * タイマー終了時に呼び出されるリスナを追加する
     * 後で登録されたものが, タイマー終了時に先に呼び出される.
     * 既に登録したものを再度登録しようとした場合, 先のものは削除され, 
     * 後のものが登録される. (すなわち呼び出し順が変更される)
     */
    Timer.prototype.addListener = function addListener( callback ) {
        var ls = this.listeners;
        // 多重登録しないように, 削除
        _removeCallbackFunc( ls, callback );
        this.listeners.push( callback );
    };

    /**
     * タイマー終了時に呼び出されるリスナを削除する
     */
    Timer.prototype.removeListener = function removeListener( callback ) {
        var ls = this.listeners;
        return ( _removeCallbackFunc( ls, callback ) !== null );
    };

    /**
     * リスナの配列の中から, 指定の関数があるか探し, あればその要素を削除する
     * 要素を削除した場合, その要素を返す. 削除しなかった場合, null を返す
     */
    var _removeCallbackFunc = function _removeCallbackFunc( ls, func ) {
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

    /**
     * タイマーを開始, または再開する
     */
    Timer.prototype.start = function start() {
        if ( this.timerId !== null ) {
            throw new Error( "Already started" );
        }
        if ( this.remTime === null ) {
            throw new Error( "Timer already ended" );
        }
        this.startTime = Date.now();
        this.timerId = setTimeout( __end__, this.remTime, this );
    };

    /**
     * タイマーを停止する
     * タイマー停止時の残り時間が記録され, タイマー再開時にはその残り時間で動作する.
     * @return タイマー停止時の残り時間 [ms]
     */
    Timer.prototype.stop = function stop() {
        if ( this.timerId === null ) {
            throw new Error( "Not exists" );
        }
        var rt = this.remTime -= Date.now() - this.startTime;
        clearTimeout( this.timerId );
        this.timerId = null;
        this.startTime = null;
        return rt;
    };

    /**
     * タイマーのカウントダウンが 0 になった時点で呼び出される内部関数
     */
    var __end__ = function __end__( timer ) {
        timer.remTime   = null;
        timer.timerId   = null;
        timer.startTime = null;
        // 後で登録されたものを先に呼び出す
        var ls  = timer.listeners;
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
