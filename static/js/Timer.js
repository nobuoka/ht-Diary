/**
 * タイマーを管理するタイマークラス
 */
var Timer = function Timer( time ) {
    /** 残り時間: 最初は指定された値で, stop, start を繰り返すと減っていく */
    this.restTime = time; // [ms]
    /** タイマー終了時に呼び出される関数たち */
    this.listeners = [];
    /** setTimeout の返り値; setTimeout でカウントダウンしていないときは null にすること */
    this.timerId   = null;
    /** 実行中の setTimeout のカウントダウンを開始した時刻; stop したときに rest_time を計算するために使う */
    this.startTime = null; // [ms]
};

Timer.prototype.addListener = function addListener( callback ) {
    this.listeners.push( callback );
};

Timer.prototype.start = function start() {
    if ( this.timer !== null ) {
        // TODO 既に動いているのでエラー
    }
    this.startTime = Date.now();
    this.timerId = setTimeout( Timer.__endOfTimer__, this.restTime, this );
};

Timer.prototype.stop = function stop() {
    if ( this.timerId === null ) {
        // TODO 存在しないのでエラー
    }
    this.restTime -= Date.now() - this.startTime;
    clearTimeout( this.timerId );
    this.timerId = null;
    this.startTime = null;
    alert( "stop: restTime " + this.restTime );
};

Timer.__endOfTimer__ = function __endOfTimer__( timer ) {
    // TODO タイマーが終了したかどうかの確認? できるのか?
    timer.timerId   = null;
    timer.startTime = null;
    var ls  = timer.listeners;
    var len = ls.length;
    var i;
    for ( i = 0; i < len; ++ i ) {
        try {
            ls[i]();
        } catch ( err ) {
            // do nothing?
        }
    }
};
