unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors, FMX.Controls3D, FMX.Objects3D,
  FMX.MaterialSources, FMX.Viewport3D, FMX.Types3D, UIntersection, FMX.Layouts,
  FMX.ListBox, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TForm1 = class(TForm)
    Viewport3D1: TViewport3D;
    Cube1: TCube;
    Plane1: TPlane;
    ColorMaterialSource1: TColorMaterialSource;
    Light1: TLight;
    Dummy1: TDummy;
    Dummy2: TDummy;
    Camera1: TCamera;
    Timer1: TTimer;
    ColorMaterialSource2: TColorMaterialSource;
    ColorMaterialSource3: TColorMaterialSource;
    Dummy3: TDummy;
    Grid3D1: TGrid3D;
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Timer1Timer(Sender: TObject);
    procedure Dummy3Render(Sender: TObject; Context: TContext3D);
    procedure Viewport3D1Gesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

  gcounter: Integer = 0;

  _MouseS: TShiftState;
  _MouseP: TPointF;

  spheres: array of TSphere;
  points: TPoint3DArray;

implementation

{$R *.fmx}

function Point3D ( p2d: TPointF; z: Real ): TPoint3D;
begin
  result.X := p2d.X;
  result.Y := p2d.Y;
  result.Z := z;
end;

procedure TForm1.Dummy3Render(Sender: TObject; Context: TContext3D);
var
  _size: Real;
  counter: Integer;
  p1, p2: TPoint3D;
begin
  _size := 2.5;
  // draw the edges
  for counter := 0 to High ( edges ) do begin
    p1 := vertices [ edges [ counter ].X ] * _size * Cube1.AbsoluteMatrix;
    p2 := vertices [ edges [ counter ].Y ] * _size * Cube1.AbsoluteMatrix;

    // draw lines
    Form1.Viewport3D1.Context.DrawLine ( p1, p2, 1, TAlphaColorRec.Yellow );
  end;



  // draw
  if length ( points ) > 1 then begin
    for counter := 0 to High ( points ) - 1 do
      Form1.Viewport3D1.Context.DrawLine ( points [ counter ], points [ counter + 1 ], 1, TAlphaColorRec.Black );
    Form1.Viewport3D1.Context.DrawLine ( points [ high ( points ) ], points [ 0 ], 1, TAlphaColorRec.Black );
  end;

  points := nil;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  index, i2, counter: Integer;
  lambda, _size: Real;
  dir, v, p1, p2: TPoint3D;
begin
  inc ( gcounter );

  _size := 2.5;

  // rotate the components
    Form1.Cube1.RotationAngle.X := Form1.Cube1.RotationAngle.X + 0.2;
    Form1.Cube1.RotationAngle.Y := Form1.Cube1.RotationAngle.Y + 0.1;
    Form1.Cube1.RotationAngle.Z := Form1.Cube1.RotationAngle.Z + 0.3;

    Form1.Cube1.Position.X := 3*sin(gcounter/30);
    Form1.Cube1.Position.Y := 1*sin(gcounter/40);
    Form1.Cube1.Position.Z := 2*sin(gcounter/60);

    Form1.Plane1.RotationAngle.X := Form1.Plane1.RotationAngle.X + 0.15;
    Form1.Plane1.RotationAngle.Y := Form1.Plane1.RotationAngle.Y + 0.25;
    Form1.Plane1.RotationAngle.Z := Form1.Plane1.RotationAngle.Z + 0.35;

    Form1.Plane1.Position.X := 1*sin(gcounter/100);
    Form1.Plane1.Position.Y := 2*sin(gcounter/150);
    Form1.Plane1.Position.Z := 3*sin(gcounter/200);

  // extract edge points
  for counter := 0 to high ( spheres ) do
    spheres [ counter ].Free;
  spheres := nil;

  // show the edges
  setlength ( spheres, 8 );
  for counter := 0 to High ( spheres ) do begin
    v := vertices [ counter ] * _size * Cube1.AbsoluteMatrix;
    spheres [ counter ] := TSphere.Create( Form1 );
    spheres [ counter ].Parent := Form1.Viewport3D1;
    spheres [ counter ].Width := 0.2;
    spheres [ counter ].Height := 0.2;
    spheres [ counter ].Depth := 0.2;
    spheres [ counter ].Position.X := v.X;
    spheres [ counter ].Position.Y := v.Y;
    spheres [ counter ].Position.Z := v.Z;
  end;


  points := Cube_Plane_Intersection ( Cube1, Plane1 );
  for counter := 0 to High ( points ) do begin
      index := Length ( spheres );
      setlength ( spheres, index + 1 );
      spheres [ index ] := TSphere.Create ( Form1 );
      spheres [ index ].Parent := Form1.Viewport3D1;
      spheres [ index ].MaterialSource := ColorMaterialSource3;
      spheres [ index ].Width := 0.2;
      spheres [ index ].Height := 0.2;
      spheres [ index ].Depth := 0.2;
      spheres [ index ].Position.X := points [ counter ].X;
      spheres [ index ].Position.Y := points [ counter ].Y;
      spheres [ index ].Position.Z := points [ counter ].Z;
  end;

end;

procedure DoZoom(aIn: boolean);
var newZ: single;
begin
  if aIn then
    newZ := Form1.Camera1.Position.Z + 1
  else
    newZ := Form1.Camera1.Position.Z - 1;

  if (newZ < 100) and (newZ > -100) then
    Form1.Camera1.Position.Z := newZ;
end;

procedure TForm1.Viewport3D1Gesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  Form1.Caption := inttostr ( EventInfo.GestureID );

  case EventInfo.GestureID of
    igiZoom: begin
      // supress onmouseevent
      _MouseS := [];


      DoZoom ( ( EventInfo.Distance - Form1.Camera1.Tag ) > 0 );
      Form1.Camera1.Tag := EventInfo.Distance;
    end;
    igiPan: begin
      // EventInfo.Location
    end;
  end;
end;

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  _MouseS := Shift;
  _MouseP := PointF ( X, Y );
end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
var
  P: TPointF;
begin
  if ssLeft in _MouseS then begin
    P := TPointF.Create( X, Y );

    with Dummy1.RotationAngle do Y := Y + ( P.X - _MouseP.X ) / 2;
    with Dummy2.RotationAngle do X := X - ( P.Y - _MouseP.Y ) / 2;

    _MouseP := P;

  end;

  if ssRight in _MouseS then begin

  end;

end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  _MouseS := [];
end;

end.
