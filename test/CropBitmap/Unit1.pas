unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

procedure CropBitmap(aBitmap: TBitmap; aRect: TRect);
var bmp:TBitmap; r: TRect;
begin
  r:=aRect; offsetRect(r,-r.left,-r.top);
  bmp:=Tbitmap.create;
  bmp.SetSize(r.right,r.bottom);

  bmp.Canvas.CopyRect(r,aBitmap.Canvas,aRect);
  aBitmap.Assign(bmp);
  bmp.free;
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var r: Trect;
begin
  r:=rect(0,0,Image1.width div 2,Image1.height div 2);
  offsetRect(r,Image1.width div 4,Image1.height div 4);
  CropBitmap(Image1.Picture.Bitmap,r);
end;

{ TForm1 }

end.

