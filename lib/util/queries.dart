const String readIntersection = """
query GetIntersection(\$intersection: ID!){
  messages {
    messages {intersection_id, spat_available, map_available}
  }
  intersection(intersectionId: \$intersection) {
    item {
      ref_position{lat, long},
      lanes {
        id,
        type,
        ingress_approach_id,
        egress_approach_id,
        approach_type
        shared_with_id,
        maneuver_id,
        connects_to {lane_id, maneuver_id, signal_group_id},
        nodes {
          offset{
            x,
            y
          }
        }
      }
    }
  }
}
""";

const String readSignalGroups = '''
query GetSignalGroups(\$intersection: ID!){
  intersection(intersectionId: \$intersection) {
    item {
      signal_groups {
        id,
        state,
        min_end_time, 
        max_end_time,
        likely_time,
        confidence
      }     
    }
  }
}
''';
