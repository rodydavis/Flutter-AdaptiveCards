
int index = 0;

Map assignIds(Map toAssign) {
  maybeAddId(toAssign);
  switch(toAssign["type"]) {
    case "AdaptiveCard":
      List<dynamic> children = toAssign["body"];
      for(dynamic child in children) {
        assignIds(child);
      }
      break;
    case "Container":
      List<dynamic> children = toAssign["items"];
      for(dynamic child in children) {
        assignIds(child);
      }
      break;

  }


  return toAssign;
}

void maybeAddId(Map toAdd) {
  if(!toAdd.containsKey("id")) {
    toAdd["id"] = index;
    index ++;
  }
}