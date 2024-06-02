class TimerData {

  String task; // task to complete
  int dur; // interval duration
  int num; // number of intervals
  int breakDur; //duration of the break

  TimerData({
    required this.task,
    required this.dur,
    required this.num,
    required this.breakDur,
  });
}