unit HelpTypes;

interface
  Uses
    Vcl.ExtCtrls, Vcl.Graphics, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls;
  Type

    pAllBlocks = ^AllBlocks;
    pBlock =  ^TBlock;

    TShapeType = (stRectangle, stCircle, stDecision, stCycle);
    TStartBlock = class(TShape)
    public
      FPen: TPen;
      FBrush: TBrush;
      FShape: TShapeType;
    public
      constructor Create (AOwner: TComponent); override;
      procedure SetBrush(Value: TBrush);
      procedure SetPen(Value: TPen);
      procedure SetShape(Value: TShapeType);
      procedure Paint; override;
      property Pen: TPen read FPen write SetPen;
      property Shape: TShapeType read FShape write SetShape default stRectangle;
    end;


    AllBlocks = record
      Block: pBlock;
      Next: pAllBlocks;
    end;

    TBlock = record
      Pen:TPen;
      Brush:TBrush;
      Text:String;
      Shape:TShapeType;
      x,y,w,h:Integer;
      Next: Array of pBlock;
      Prev: pBlock;
      ownCanvas:TCanvas;
    end;

    TProEdit = class(TRichEdit)
    public
      prev: pBlock;
    end;

    procedure DrawBlock(bl: pBlock);

implementation

constructor TStartBlock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 50;
  Height := 50;
  FPen := TPen.Create;
  FPen.OnChange := StyleChanged;
  FBrush := TBrush.Create;
  FBrush.OnChange := StyleChanged;
end;

procedure TStartBlock.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TStartBlock.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TStartBlock.SetShape(Value: TShapeType);
begin
  if FShape <> Value then
  begin
    FShape := Value;
    Invalidate;
  end;
end;

procedure TStartBlock.Paint;
var
  X, Y, W, H, S: Integer;
begin

  with Canvas do
  begin
    Pen := FPen;
    Brush := FBrush;
    W := Width - Pen.Width + 1;
    H := Height - Pen.Width + 1;
    X := Pen.Width div 2;
    Y := X;
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    case FShape of
      stRectangle:
        Rectangle(X+1, Y+1, X + W-1, Y + H-1);
      stCircle:
        Ellipse(X, Y, X + W-1, Y + H-1);
      stDecision:
      begin

        Polygon([Point(x+w-1, y+h div 2),
                 Point(x+w div 2,y+h-1),
                 Point(x,y+h div 2),
                 Point(x+w div 2,y)]);
      end;
      stCycle:
      begin
        Polygon([Point(x+(w div 3)*2, y),
                 Point(x+w-1, y+h div 2),
                 Point(x+(w div 3)*2, y+h-1),
                 Point(x+(w div 3), y+h-1),
                 Point(x,y+h div 2),
                 Point(x+w div 3,y)]);
      end;
    end;
  end;
end;

procedure DrawBlock(bl: pBlock);
begin
  bl.ownCanvas.Pen := bl.Pen;
  bl.ownCanvas.Brush := bl.Brush;
  with bl.ownCanvas do
  begin
    Pen := bl.Pen;
    Brush := bl.Brush;
    case bl.Shape of
      stRectangle:
        Rectangle(bl.X, bl.Y, bl.X + bl.W, bl.Y + bl.H);
      stCircle:
        Ellipse(bl.X, bl.Y, bl.X + bl.W, bl.Y + bl.H);
      stDecision:
      begin

        Polygon([Point(bl.x+bl.w, bl.y+bl.h div 2),
                 Point(bl.x+bl.w div 2,bl.y+bl.h),
                 Point(bl.x,bl.y+bl.h div 2),
                 Point(bl.x+bl.w div 2,bl.y)]);
      end;
      stCycle:
      begin
        Polygon([Point(bl.x+(bl.w div 3)*2, bl.y),
                 Point(bl.x+bl.w, bl.y+bl.h div 2),
                 Point(bl.x+(bl.w div 3)*2, bl.y+bl.h),
                 Point(bl.x+(bl.w div 3), bl.y+bl.h),
                 Point(bl.x,bl.y+bl.h div 2),
                 Point(bl.x+bl.w div 3,bl.y)]);
      end;
    end;
  end;
end;


end.
