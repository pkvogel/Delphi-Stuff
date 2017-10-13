unit UIntersection;

interface

uses
  System.Types, System.Math, System.Math.Vectors, FMX.Objects3D;

type
  TIPoint3D = packed record
    x, y, dir: Integer;
  end;

  TPoint3DArray = array of TPoint3D;

  // ** exports **
  function Cube_Plane_Intersection ( _cube: TCube; _plane: TPlane ): TPoint3DArray;

  procedure QuickSortAngle(var A: TPoint3DArray; var Angles: array of Real; iLo, iHi: Integer);


var
  // dummy
  vertices: array of TPoint3D;
  edges: array of TIPoint3D; // stores the indices of vertices

implementation

// calculates the intersection polygone
function Cube_Plane_Intersection ( _cube: TCube; _plane: TPlane ): TPoint3DArray;
var
  dl, lambda, _size: Real;
  index, counter: Integer;
  v, dir, p0, p1, p2, p3: TPoint3D;
  angles: array of real;

  function dotproduct ( v1, v2: TPoint3D ): Real;
  begin
    result := v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z;
  end;

begin
  result := nil;

  // calc intersection
  for counter := 0 to High ( edges ) do begin

    // get the size in the direction
    case edges [ counter ].dir of
      1: _size := _cube.Width / 2;
      2: _size := _cube.Height / 2;
      3: _size := _cube.Depth / 2;
    end;
    // calculate the real position of the vertices
    p1 := vertices [ edges [ counter ].X ] * _size * _Cube.AbsoluteMatrix;
    p2 := vertices [ edges [ counter ].Y ] * _size * _Cube.AbsoluteMatrix;

    // calculate the intersection
    v := p1;
    dir := p2 - p1;
    p3 := _plane.AbsoluteDirection;
    dl := p3.DotProduct ( _plane.AbsolutePosition );
    lambda := ( dl - _plane.AbsoluteDirection.DotProduct ( v ) ) / ( _plane.AbsoluteDirection.DotProduct ( dir ) );
    if ( lambda >= 0 ) and ( lambda <= 1 ) then begin
      v := v + lambda * dir;

      //
      index := length ( result );
      setlength ( result, index + 1 );
      result [ index ] := v;
    end;

  end;

  // reorder the vertices if necessary
  if length ( result ) > 3 then begin
    setlength ( angles, length ( result ) );

    // get the center
    p0 := p0.Zero;
    for counter := 0 to High ( result ) do
      p0 := p0 + result [ counter ];
    p0 := p0 / length ( result );

    // calc the angles between
    p1 := _plane.AbsoluteUp;// result [ 0 ] - p0;
    p1 := p1.Normalize;
    for counter := 0 to High ( result ) do begin
      p2 := result [ counter ] - p0;
      p2 := p2.Normalize;
      angles [ counter ] := sign ( p1.CrossProduct ( p2 ).DotProduct ( _plane.AbsoluteDirection ) ) * arccos ( ensurerange ( p1.DotProduct ( p2 ), -1, 1 ) );
      if angles [ counter ] < 0 then
        angles [ counter ] := 2*pi+angles [ counter ];

    end;

    QuickSortAngle ( result, angles, 0, high ( result ) );

    angles := nil;
  end;



  // calc intersection
  // http://cococubed.asu.edu/code_pages/raybox.shtml
  // todo


end; // <- Cube_Plane_Intersection

// sort an array of points by angle
procedure QuickSortAngle(var A: TPoint3DArray; var Angles: array of Real; iLo, iHi: Integer);
var
  Lo, Hi: Integer;
  Mid: Real;
  TempPoint: TPoint3D;
  TempAngle: Real;
begin
  Lo  := iLo;
  Hi  := iHi;
  Mid := Angles[(Lo + Hi) div 2];
  repeat
    while Angles[Lo] < Mid do Inc(Lo);
    while Angles[Hi] > Mid do Dec(Hi);
    if Lo <= Hi then
    begin
      // swap points
      TempPoint := A[Lo];
      A[Lo] := A[Hi];
      A[Hi] := TempPoint;
      // swap angles
      TempAngle := Angles[Lo];
      Angles[Lo] := Angles[Hi];
      Angles[Hi] := TempAngle;
      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  // perform quicksorts on subsections
  if Hi > iLo then QuickSortAngle(A, Angles, iLo, Hi);
  if Lo < iHi then QuickSortAngle(A, Angles, Lo, iHi);
end;


initialization
  setlength ( vertices, 8 );
  vertices [ 0 ].X := 1;
  vertices [ 0 ].Y := 1;
  vertices [ 0 ].Z := 1;
  vertices [ 1 ].X := -1;
  vertices [ 1 ].Y := 1;
  vertices [ 1 ].Z := 1;
  vertices [ 2 ].X := -1;
  vertices [ 2 ].Y := 1;
  vertices [ 2 ].Z := -1;
  vertices [ 3 ].X := 1;
  vertices [ 3 ].Y := 1;
  vertices [ 3 ].Z := -1;
  vertices [ 4 ].X := 1;
  vertices [ 4 ].Y := -1;
  vertices [ 4 ].Z := 1;
  vertices [ 5 ].X := -1;
  vertices [ 5 ].Y := -1;
  vertices [ 5 ].Z := 1;
  vertices [ 6 ].X := -1;
  vertices [ 6 ].Y := -1;
  vertices [ 6 ].Z := -1;
  vertices [ 7 ].X := 1;
  vertices [ 7 ].Y := -1;
  vertices [ 7 ].Z := -1;

  setlength ( edges, 12 );
  edges [ 0 ].X := 0;
  edges [ 0 ].Y := 1;
  edges [ 0 ].dir := 1;  // x-direction
  edges [ 1 ].X := 1;
  edges [ 1 ].Y := 2;
  edges [ 1 ].dir := 3;  // z-direction
  edges [ 2 ].X := 2;
  edges [ 2 ].Y := 3;
  edges [ 2 ].dir := 1;  // x-direction
  edges [ 3 ].X := 3;
  edges [ 3 ].Y := 0;
  edges [ 3 ].dir := 3;  // z-direction
  edges [ 4 ].X := 4;
  edges [ 4 ].Y := 5;
  edges [ 4 ].dir := 1;  // x-direction
  edges [ 5 ].X := 5;
  edges [ 5 ].Y := 6;
  edges [ 5 ].dir := 3;  // z-direction
  edges [ 6 ].X := 6;
  edges [ 6 ].Y := 7;
  edges [ 6 ].dir := 1;  // x-direction
  edges [ 7 ].X := 7;
  edges [ 7 ].Y := 4;
  edges [ 7 ].dir := 3;  // z-direction
  edges [ 8 ].X := 0;
  edges [ 8 ].Y := 4;
  edges [ 8 ].dir := 2;  // y-direction
  edges [ 9 ].X := 1;
  edges [ 9 ].Y := 5;
  edges [ 9 ].dir := 2;  // y-direction
  edges [ 10 ].X := 2;
  edges [ 10 ].Y := 6;
  edges [ 10 ].dir := 2; // y-direction
  edges [ 11 ].X := 3;
  edges [ 11 ].Y := 7;
  edges [ 11 ].dir := 2; // y-direction

finalization
  vertices := nil;
  edges := nil;

end.
