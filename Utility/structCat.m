function cat = structCat(str,direction)
% structCat Concatenate field values of a struct

arguments
  str (1,1) struct
  direction (1,1) string {mustBeMember(direction,["horz","vert"])} = "horz"
end

str = struct2cell(str);
if direction == "horz"
  cat = [str{:}];
else
  cat = vertcat(str{:});
end