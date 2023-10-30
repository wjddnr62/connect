class TrackingGraph {
  final List<dynamic> dates;
  final List<dynamic> steps;
  final List<dynamic> uppers;
  final List<dynamic> lowers;
  final List<dynamic> wholes;
  final List<dynamic> socials;

  TrackingGraph(
      {this.dates,
      this.steps,
      this.uppers,
      this.lowers,
      this.wholes,
      this.socials});

  factory TrackingGraph.fromJson(Map<String, dynamic> data) {
    return TrackingGraph(
        dates: data['dates'] as List,
        steps: data['steps'] as List,
        uppers: data['uppers'] as List,
        lowers: data['lowers'] as List,
        wholes: data['wholes'] as List,
        socials: data['socials'] as List);
  }
}
