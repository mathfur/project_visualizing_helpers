# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::Railroad2CSV do
  describe '#initialize' do
    def nodes(input)
      ProjectVisualizingHelpers::Railroad2CSV.new(input).nodes.sort
    end

    def edges(input)
      ProjectVisualizingHelpers::Railroad2CSV.new(input).edges
    end

    specify do
      nodes(<<-EOS).should == ["Group", "GroupMembership", "Report", "User"]
digraph models_diagram {
     graph[overlap=false, splines=true]
     "Report" [shape=Mrecord, label="{Report|title :string\lcreated_at :datetime\l}"]
     "User" -> "Group" [label="foo", arrowtail=crow, arrowhead=dot, dir=both]
     "User" -> "GroupMembership" [arrowtail=crow, arrowhead=dot, dir=both]
}
      EOS
    end

    specify do
      edges(<<-EOS).should == [["User", "Group"], ["User", "GroupMembership"]]
digraph models_diagram {
     graph[overlap=false, splines=true]
     "Report" [shape=Mrecord, label="{Report|title :string\lcreated_at :datetime\l}"]
     "User" -> "Group" [label="foo", arrowtail=crow, arrowhead=dot, dir=both]
     "User" -> "GroupMembership" [arrowtail=crow, arrowhead=dot, dir=both]
}
      EOS
    end
  end
end
