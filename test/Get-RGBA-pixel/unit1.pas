unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Graphics, Dialogs, StdCtrls, ExtCtrls, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    lblPixelFormat: TLabel;
    lblInfo: TLabel;
    OpenDialog1: TOpenDialog;
    Shape1: TShape;
    procedure Button1Click(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
  private
    LoadedPixelFormat: TPixelFormat;
    procedure LoadJPEG;
    procedure LoadBMP;
    procedure LoadPNG;
    procedure GetRGB(X, Y: Integer; out R, G, B: Byte; out Alpha: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  FileExt: string;
begin

  if not(OpenDialog1.Execute) then Exit;

  Image1.Enabled := True;
  lblPixelFormat.Visible := True;
  lblInfo.Visible := True;

  // Open the file
  FileExt := LowerCase(ExtractFileExt(OpenDialog1.FileName));
  case FileExt of
    '.jpg', '.jpeg', 'jpe': LoadJPEG;
    '.png':                 LoadPNG;
    '.bmp':                 LoadBMP;
  end;

  // Show Pixel Format info
  case LoadedPixelFormat of
    pfDevice:  lblPixelFormat.Caption := 'Pixel Format'+#13+'Device';
    pf1bit:    lblPixelFormat.Caption := 'Pixel Format'+#13+'1-bit';
    pf4bit:    lblPixelFormat.Caption := 'Pixel Format'+#13+'4-bit';
    pf8bit:    lblPixelFormat.Caption := 'Pixel Format'+#13+'8-bit';
    pf15bit:   lblPixelFormat.Caption := 'Pixel Format'+#13+'15-bit';
    pf16bit:   lblPixelFormat.Caption := 'Pixel Format'+#13+'16-bit';
    pf24bit:   lblPixelFormat.Caption := 'Pixel Format'+#13+'24-bit';
    pf32bit:   lblPixelFormat.Caption := 'Pixel Format'+#13+'32-bit';
    pfCustom:  lblPixelFormat.Caption := 'Pixel Format'+#13+'Custom';
  end;

  // Clear previous info
  Shape1.Brush.Color := clBackground;
  lblInfo.Caption := '';

end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ValR, ValG, ValB: Byte;
  Alpha: string;
begin
  if (LoadedPixelFormat = pf24bit) or (LoadedPixelFormat = pf32bit) then
  begin
    GetRGB(X, Y, ValR, ValG,ValB, Alpha);
    Shape1.Brush.Color := RGBToColor(ValR, ValG, ValB);
    lblInfo.Caption :=
      'X = '+IntToStr(X)+    #13+
      'Y = '+IntToStr(Y)+    #13+
      'R = '+IntToStr(ValR)+ #13+
      'G = '+IntToStr(ValG)+ #13+
      'B = '+IntToStr(ValB)+ #13+
      Alpha;
  end;
end;

procedure TForm1.LoadJPEG;
var
  AJpg:  TJPEGImage;
begin
  AJpg := TJpegImage.Create;
  try
    AJpg.LoadFromFile(OpenDialog1.FileName);
    Image1.Picture.Bitmap.Assign(AJpg);
  finally
    AJpg.Free;
  end;
  LoadedPixelFormat := pf32bit;
end;

procedure TForm1.LoadBMP;
var
  ABmp:  TBitmap;
begin
  ABmp := TBitmap.Create;
  try
    ABmp.LoadFromFile(OpenDialog1.FileName);
    Image1.Picture.Bitmap.Assign(ABmp);
  finally
    ABmp.Free;
  end;
  LoadedPixelFormat := Image1.Picture.Bitmap.PixelFormat;
end;

procedure TForm1.LoadPNG;
var
  APNG: TPortableNetworkGraphic;
begin
  APNG := TPortableNetworkGraphic.Create;
  try
    APNG.LoadFromFile(OpenDialog1.FileName);
    Image1.Picture.Bitmap.Assign(APNG);
  finally
    APNG.Free;
  end;
  LoadedPixelFormat := Image1.Picture.Bitmap.PixelFormat;
end;

procedure TForm1.GetRGB(X, Y: Integer; out R, G, B: Byte; out Alpha: string);
var
  ScanData:  Pointer;
  Data24bit: PRGBTriple absolute ScanData;
  Data32bit: PRGBQuad   absolute ScanData;
begin
  ScanData := Image1.Picture.Bitmap.ScanLine[Y];
  case LoadedPixelFormat of
    pf24bit:
      begin
        Inc(ScanData, X * 3);
        R := Data24bit^.rgbtRed;
        G := Data24bit^.rgbtGreen;
        B := Data24bit^.rgbtBlue;
        Alpha := '';
      end;
    pf32bit:
      begin
        Inc(ScanData, X * 4);
        R := Data32bit^.rgbRed;
        G := Data32bit^.rgbGreen;
        B := Data32bit^.rgbBlue;
        Alpha := 'A = ' + IntToStr(Data32bit^.rgbReserved);
      end;
  end;
end;

end.
