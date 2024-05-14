unit UFiles;

interface
  Uses HelpTypes;
  Type
    TArrBlocks = Array of pBlock;
    TArrInt = Array of Integer;

  procedure ConverteToMas(bl: pBlock; var Arr: TArrBlocks; var ArrPrev, ArrPos: TArrInt; var numCur: Integer; numPrev:Integer =-1);
  Procedure DestroyAll(el:pAllBlocks);
  function ConverteToTree(Arr: TArrBlocks; ArrPrev, ArrPos: TArrInt):pBlock;

implementation

procedure ConverteToMas(bl: pBlock; var Arr: TArrBlocks; var ArrPrev, ArrPos: TArrInt; var numCur: Integer; numPrev:Integer =-1);
var
  n:Integer;
begin

  if bl.Prev=nil then
  begin
    setlength(Arr,10);
    Arr[0]:=bl;

    setlength(ArrPrev,10);
    ArrPrev[0]:=-1;

    setlength(ArrPos,10);
    ArrPos[0]:=0;
  end
  else
  begin
    if numCur>=length(Arr) then
    begin
      setlength(Arr,length(Arr)+10);
      setlength(ArrPrev,length(Arr));
      setlength(ArrPos,length(Arr));
    end;
    Arr[numCur]:=bl;

    ArrPrev[numCur]:=numPrev;

    n:=High(bl.Prev.Next);
    while bl.Prev.Next[n]<>bl do
      dec(n);
    ArrPos[numCur]:=n;
  end;


  numPrev:=numCur;

  for var i := High(bl.Next) downto Low(bl.Next) do
    if bl.Next[i]<>nil then
    begin
      inc(numCur);
      ConverteToMas(bl.Next[i],Arr,ArrPrev,ArrPos,numCur,numPrev);
    end;

end;

function ConverteToTree(Arr: TArrBlocks; ArrPrev, ArrPos: TArrInt):pBlock;
var
  n,i: Integer;
begin
  for I := Low(Arr) to High(Arr) do
  begin
    case Arr[i].Shape of
    stRectangle, stCycle:
        SetLength(Arr[i].Next, 2);

    stDecision:
        SetLength(Arr[i].Next, 3);

    stCircle, stTerminator:
        SetLength(Arr[i].Next, 1);
    end;
  end;

  for i := Low(ArrPrev)+1 to High(ArrPrev) do
  begin
    Arr[i].Prev:=Arr[ArrPrev[i]];
    n:=ArrPos[i];
    Arr[ArrPrev[i]].Next[n]:=Arr[i];
  end;

  Result:=Arr[0];
end;

Procedure DestroyDiag(bl:pBlock);
var
  n:Integer;
begin
  for var i := Low(bl.Next) to High(bl.Next) do
    if bl.Next[i]<>nil then
      DestroyDiag(bl.Next[i]);

  if bl.Prev<>nil then
  begin
    n:=High(bl.Prev.Next);
    while bl.Prev.Next[n]<>bl do
      dec(n);
    bl.Prev.Next[n]:=nil;
    bl.Prev:=nil;
  end;

  Dispose(bl);
end;

Procedure DestroyAll(el:pAllBlocks);
var
  n:Integer;
  temp: pAllBlocks;
begin
  while el.Next<>nil do
  begin
    temp:=el;
    el:=el.Next;
    Dispose(temp);
    DestroyDiag(el.Block);
  end;
  Dispose(el);
end;

end.
