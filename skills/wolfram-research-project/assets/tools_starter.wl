(* ::Package:: *)
(* Tools.wl — Shared graph utilities *)

HausdorffDistance::usage = "HausdorffDistance[d, setX, setY] computes the Hausdorff distance between two sets using a distance matrix or graph.";
HausdorffDistance[ d_List, setX_, setY_ ] :=
  With[ { distSubMatrix = d[[ setX, setY ]] },
    Max[ Max[ Min /@ distSubMatrix ], Max[ Min /@ Transpose @ distSubMatrix ] ]
  ]

HausdorffDistance[ g_Graph, setX_List, setY_List ] :=
  With[ { distSubMatrix = Outer[ GraphDistance[ g, #1, #2 ] &, setX, setY, 1 ] },
    Max[ Max[ Min /@ distSubMatrix ], Max[ Min /@ Transpose @ distSubMatrix ] ]
  ]

FrechetDistance::usage = "FrechetDistance[d, setX, setY, f] computes distances between point sets using function f (default Max for Frechet distance).";
FrechetDistance[ d_List, setX_, setY_, f_ : Max ] :=
  f[ Diagonal[ d[[ setX, setY ]] ] ]

FrechetDistance[ g_Graph, setX_List, setY_List, f_ : Max ] :=
  f[ Diagonal[ Outer[ GraphDistance[ g, #1, #2 ] &, setX, setY, 1 ] ] ]

Separation::usage = "Separation[d, setX, setY] finds the minimum distance between two sets.";
Separation[ d_List, setX_, setY_ ] :=
  Min[ d[[ setX, setY ]] ]

Separation[ g_Graph, setX_List, setY_List ] :=
  Min[ Outer[ GraphDistance[ g, #1, #2 ] &, setX, setY, 1 ] ]

CentralElement::usage = "CentralElement[distanceMatrix, n] finds n most central elements in a distance matrix using maxmin criterion.";
CentralElement[ distanceMatrix_List, n_ : 1 ] :=
  Module[ { scores, minScore, pool, selected, remaining },
    scores = Max /@ distanceMatrix;
    minScore = Min[ scores ];
    pool = Flatten @ Position[ scores, minScore ];
    If[ Length[ pool ] <= n, pool,
      selected = { First @ pool };
      remaining = Rest @ pool;
      Do[
        With[ { best = First @ MaximalBy[ remaining, idx |-> Min[ distanceMatrix[[ idx, selected ]] ] ] },
          AppendTo[ selected, best ];
          remaining = DeleteCases[ remaining, best ]
        ],
        { n - 1 }
      ];
      selected
    ]
  ]

GeodesicSubgraph::usage = "GeodesicSubgraph[g, pairs, opts] extracts geodesic paths connecting pairs of vertices.";
Options[ GeodesicSubgraph ] = { "PathThickness" -> 0, "Directed" -> True };

GeodesicSubgraph[ g_, pairs_, OptionsPattern[] ] :=
  Module[ { distMatrix, thickness, vertexToIndex, selectedPaths, directed },
    thickness = OptionValue[ "PathThickness" ];
    directed = OptionValue[ "Directed" ];
    vertexToIndex = AssociationThread[ VertexList[ g ], Range @ VertexCount[ g ] ];
    distMatrix = GraphDistanceMatrix[ g ];
    selectedPaths = Which[
      thickness === 0,
      ( First @ FindPath[ g, #1, #2, { distMatrix[[ vertexToIndex[ #1 ], vertexToIndex[ #2 ] ]] }, 1 ] & ) @@@ pairs,
      thickness === Infinity,
      Flatten[ ( FindPath[ g, #1, #2, { distMatrix[[ vertexToIndex[ #1 ], vertexToIndex[ #2 ] ]] }, All ] & ) @@@ pairs, 1 ],
      True,
      Flatten[
        ( If[ # === {}, {},
            With[ { ref = vertexToIndex /@ First[ # ] },
              Select[ #, path |-> HausdorffDistance[ distMatrix, vertexToIndex /@ path, ref ] <= thickness ]
            ]
          ] & ) /@
        ( ( FindPath[ g, #1, #2, { distMatrix[[ vertexToIndex[ #1 ], vertexToIndex[ #2 ] ]] }, All ] & ) @@@ pairs ),
        1
      ]
    ];
    GraphUnion @@ ( PathGraph[ #, DirectedEdges -> directed ] & /@ selectedPaths )
  ]
