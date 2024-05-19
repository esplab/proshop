unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ShellCtrls,
  EditBtn, ComCtrls, Buttons, Spin, BGRABitmap, BGRABitmapTypes, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ColorButton1: TColorButton;
    DirectoryEdit1: TDirectoryEdit;
    Panel5: TPanel;
    CropPanel: TPanel;
    Image: TImage;
    ImageList1: TImageList;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel6: TPanel;
    ScrollBox1: TScrollBox;
    Sel: TShape;
    ShellListView1: TShellListView;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    doCrop: TSpeedButton;
    cancelCrop: TSpeedButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure DirectoryEdit1AcceptDirectory(Sender: TObject; var Value: string);
    procedure FormShow(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure SelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure doCropClick(Sender: TObject);
    procedure cancelCropClick(Sender: TObject);
    procedure ShellListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure SpinEdit4Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    _RectStart, _RectStop: TPoint;
    _StartSelect: boolean;
    procedure DrawRect(P1, P2: TPoint);
    procedure UpdateCropCoords;
    procedure ToggleCropPanel(panelVisibility: boolean);
    function CompareImages(imageToCompare1, imageToCompare2: TImage): boolean;
    procedure ResizeBitmapCanvas(Bitmap: TBitmap; W, H: integer; BackColor: TColor);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  _RectStart.X := x;
  _RectStart.Y := Y;
  _StartSelect := True;
  Sel.Left := X;
  Sel.Top := Y;
  Sel.Width := 0;
  Sel.Height := 0;
  Sel.Visible := True;
  ToggleCropPanel(True);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShellListView1.Root := DirectoryEdit1.Directory;
  form1.Caption := DirectoryEdit1.Directory;
end;

procedure TForm1.DirectoryEdit1AcceptDirectory(Sender: TObject; var Value: string);
begin
  ShellListView1.Root := Value;
  form1.Caption := Value;
end;

procedure TForm1.ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  if _StartSelect then
  begin
    _RectStop.X := X;
    _RectStop.Y := Y;
    DrawRect(_RectStart, _RectStop);
    UpdateCropCoords;
  end;
end;

procedure TForm1.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if _StartSelect then
  begin
    _RectStop.X := X;
    _RectStop.Y := Y;
    DrawRect(_RectStart, _RectStop);
    _StartSelect := False;
  end;
end;

procedure TForm1.SelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  Sel.Visible := False;
end;

procedure TForm1.doCropClick(Sender: TObject);
var
  bmp: TBitmap;
  r: TRect;
begin
  ToggleCropPanel(False);
  Sel.Visible := False;

  r := rect(Sel.Left, Sel.Top, Sel.Left + Sel.Width, Sel.Top + Sel.Height);
  bmp := Tbitmap.Create;
  bmp.SetSize(r.Width, r.Height);

  bmp.Canvas.CopyRect(rect(0, 0, Sel.Width, Sel.Height), Image.Picture.Bitmap.Canvas, r);

  Image.Picture.Bitmap.Assign(bmp);
  Image.Width := Sel.Width;
  Image.Height := Sel.Height;

  bmp.Free;

end;

procedure TForm1.cancelCropClick(Sender: TObject);
begin
  ToggleCropPanel(False);
  Sel.Visible := False;
end;

procedure TForm1.ShellListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: boolean);
begin
  Image.Picture.LoadFromFile(DirectoryEdit1.Text + '/' + item.Caption);
  //  Label1.Caption := IntToStr(image1.Width) + ' x ' + IntToStr(image1.Height);
  Form1.Caption := DirectoryEdit1.Text + '/' + item.Caption;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  ResizeBitmapCanvas(Image.Picture.Bitmap, 640, 640, clWhite);
  ShellListView1.SetFocus;
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  Sel.Left := SpinEdit1.Value;
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
  Sel.Top := SpinEdit2.Value;
end;

procedure TForm1.SpinEdit3Change(Sender: TObject);
begin
  Sel.Width := SpinEdit3.Value;
end;

procedure TForm1.SpinEdit4Change(Sender: TObject);
begin
  Sel.Height := SpinEdit4.Value;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if Sel.Pen.Style = psDashDotDot then
    Sel.Pen.Style := psDashDot
  else
    Sel.Pen.Style := psDashDotDot;
end;


procedure TForm1.DrawRect(P1, P2: TPoint);
var
  Temp: integer;
  T: TRect;
begin

  if P1.X > P2.X then
  begin
    Temp := P1.X;
    P1.X := P2.X;
    P2.X := Temp;
  end;

  if P1.Y > P2.Y then
  begin
    Temp := P1.Y;
    P1.Y := P2.Y;
    P2.Y := Temp;
  end;

  T := Rect(P1.X, P1.Y, P2.X, P2.Y);
  Sel.Left := P1.X;
  Sel.Top := P1.X;
  Sel.Width := T.Width;
  Sel.Height := T.Height;
end;

procedure TForm1.UpdateCropCoords;
begin
  SpinEdit1.Value := Sel.Left;
  SpinEdit2.Value := Sel.Top;
  SpinEdit3.Value := Sel.Width;
  SpinEdit4.Value := Sel.Height;
end;

procedure TForm1.ToggleCropPanel(panelVisibility: boolean);
begin
  CropPanel.Visible := panelVisibility;
end;

function TForm1.CompareImages(imageToCompare1, imageToCompare2: TImage): boolean;
var
  memImg1, memImg2: TStream;
begin
  memImg1 := TMemoryStream.Create;
  memImg2 := TMemoryStream.Create;

  imageToCompare1.Picture.Bitmap.SaveToStream(memImg1);
  imageToCompare2.Picture.Bitmap.SaveToStream(memImg2);

  Result := (memImg1.Size = memImg2.Size);

  memImg1.Free;
  memImg2.Free;
end;

procedure TForm1.ResizeBitmapCanvas(Bitmap: TBitmap; W, H: integer; BackColor: TColor);
var
  Bmp: TBitmap;
  Source, Dest: TRect;
  Xshift, Yshift: integer;
begin
  Xshift := (Bitmap.Width - W) div 2;
  Yshift := (Bitmap.Height - H) div 2;

  Source.Left := Max(0, Xshift);
  Source.Top := Max(0, Yshift);
  Source.Width := Min(W, Bitmap.Width);
  Source.Height := Min(H, Bitmap.Height);

  Dest.Left := Max(0, -Xshift);
  Dest.Top := Max(0, -Yshift);
  Dest.Width := Source.Width;
  Dest.Height := Source.Height;

  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(W, H);
    Bmp.Canvas.Brush.Style := bsSolid;
    Bmp.Canvas.Brush.Color := BackColor;
    Bmp.Canvas.FillRect(Rect(0, 0, W, H));
    Bmp.Canvas.CopyRect(Dest, Bitmap.Canvas, Source);
    Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;

end;

end.
