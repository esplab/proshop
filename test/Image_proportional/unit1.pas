unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Bevel1: TBevel;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    PageControl1: TPageControl;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Label3.Caption := Format('Original size %d x %d', [Image1.Picture.Width, Image1.Picture.Height]);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Label4.Caption := Format('Image size %d x %d', [Image1.Width, Image1.Height]);
  Label5.Caption := Format('Image size %d x %d', [Image2.Width, Image2.Height]);
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  aspectratio: Double;
  wpic, hpic: Integer;
  w, h: Integer;
begin
  // Original size of picture
  wpic := Image1.Picture.Width;
  hpic := Image1.Picture.Height;
  // Original picture is "wider than high" in relation to the drawing canvas
  if wpic / hpic > Paintbox1.Width / Paintbox1.Height then begin
    w := Paintbox1.Width;
    h := round(Paintbox1.Width * hpic / wpic);
  end else begin
    h := Paintbox1.Height;
    w := round(Paintbox1.Height * wpic / hpic);
  end;
  Paintbox1.Canvas.StretchDraw(Rect(0, 0, w, h), Image1.Picture.Bitmap);
end;

end.

