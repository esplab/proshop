unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, ShellCtrls,
  EditBtn, ExtCtrls, ComCtrls, StdCtrls, Buttons, Math, FPImage,IntfGraphics,GraphType;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    DirectoryEdit1: TDirectoryEdit;
    Image1: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    ScrollBox1: TScrollBox;
    ShellListView1: TShellListView;
    Splitter1: TSplitter;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DirectoryEdit1AcceptDirectory(Sender: TObject; var Value: string);
    procedure FormShow(Sender: TObject);
    procedure ShellListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
    procedure ToggleBox1Change(Sender: TObject);

  private

  public
    procedure ResizeBitmapCanvas(Bitmap: TBitmap; H, W: Integer; BackColor: TColor);
    procedure CreatePNG;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.DirectoryEdit1AcceptDirectory(Sender: TObject; var Value: string);
begin
  ShellListView1.Root := Value;
  Form1.Caption := Value;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Item: TListItem;
  GoodFile: string;
  si:LongInt;
begin
  GoodFile := ShellListView1.Selected.Caption;
  form1.Caption := GoodFile;

  si := ShellListView1.Selected.Index;

  item := ShellListView1.Items[si];
  item.Free;

  ShellListView1.Items[si].Selected:=true;

  if RenameFile(DirectoryEdit1.Directory + '\' + GoodFile, DirectoryEdit1.Directory +
    '\Good\' + GoodFile) then
  begin
    form1.Caption := Form1.Caption + ' moved to successfully to Good';
  end;
  ShellListView1.SetFocus;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Item: TListItem;
  GoodFile: string;
  si:LongInt;
begin
  GoodFile := ShellListView1.Selected.Caption;
  form1.Caption := GoodFile;

  si := ShellListView1.Selected.Index;

  item := ShellListView1.Items[si];
  item.Free;

  ShellListView1.Items[si].Selected:=true;

  if RenameFile(DirectoryEdit1.Directory + '\' + GoodFile, DirectoryEdit1.Directory +
    '\Bad\' + GoodFile) then
  begin
    form1.Caption := Form1.Caption + ' moved to successfully to Bad';
  end;
  ShellListView1.SetFocus;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShellListView1.Root := DirectoryEdit1.Directory;
  Form1.Caption := DirectoryEdit1.Directory;
end;


procedure TForm1.ShellListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: boolean);
begin
  image1.Picture.LoadFromFile(DirectoryEdit1.Text + '\' + item.Caption);
  Label1.Caption := IntToStr(image1.Width) + ' x ' + IntToStr(image1.Height);
  Form1.Caption := DirectoryEdit1.Text + '\' + item.Caption;
end;

procedure TForm1.ToggleBox1Change(Sender: TObject);
begin
  ResizeBitmapCanvas(Image1.Picture.Bitmap, 640, 640, clWhite);
  ShellListView1.SetFocus;
end;

procedure TForm1.ResizeBitmapCanvas(Bitmap: TBitmap; H, W: Integer; BackColor: TColor);
var
  Bmp: TBitmap;
  Source, Dest: TRect;
  Xshift, Yshift: Integer;
begin
  Xshift := (Bitmap.Width-W) div 2;
  Yshift := (Bitmap.Height-H) div 2;

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

procedure TForm1.CreatePNG;
//Requires FPImage,IntfGraphics,GraphType in uses clause
var
 img: TLazIntfImage;
 png: TPortableNetworkGraphic;
 col: TFPColor;
 x,y: Integer;
begin
 //Creates and fills a PNG, then converts to BMP
 png:=TPortableNetworkGraphic.Create;
 png.PixelFormat:=pf32bit; //32bpp is required for the alpha channel
 img:=TLazIntfImage.Create(0,0,[riqfRGB, riqfAlpha]);
 img.SetSize(256,256);
 for y:=0 to img.Height-1 do
  for x:=0 to img.Width-1 do
  begin
   // $FF is non-transparent down to $00 fully transparent
   col.Alpha:=(128-(x div 2))+(128-(y div 2));
   col.Red  :=x;
   col.Green:=y;
   col.Blue :=(128-(x div 2))+(128-(y div 2));
   //TFPColor is 16 bit per colour
   col.Alpha:=col.Alpha or col.Alpha<<8;
   col.Red  :=col.Red or col.Red<<8;
   col.Green:=col.Green or col.Green<<8;
   col.Blue :=col.Blue or col.Blue<<8;
   //Set the pixel colour
   img.Colors[x,y]:=col;
  end;
 //Save to PNG
 png.LoadFromIntfImage(img);
 //And to file
 png.SaveToFile('Test.png');
 //Load into the picture, so we can see it...and convert to BMP at the same time
 ///Image2.Picture.Bitmap.PixelFormat:=pf32bit;
 ///Image2.Picture.Bitmap.Assign(png);
 //Save to file
 ///Image2.Picture.Bitmap.SaveToFile('Test.bmp');
 img.Free;
 png.Free;
end;


end.
