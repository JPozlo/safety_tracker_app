class Run{
  final double distance;
  final DateTime startTime;
  final DateTime endTime;
  final String userId;

 const Run({this.distance, this.startTime, this.endTime, this.userId});

  factory Run.fromJson(Map<String, dynamic> json){
    return Run(
      distance: json['distance'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      userId: json['userId'],
    );
  }
}