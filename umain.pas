unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  BGRAVirtualScreen, BGRABitmap, BGRABitmapTypes, BCTypes, Registry, Windows,
  LMEssages;

const
  BLURSIZE = 50;
  ALPHAVALUE = 100;

type

  { TForm1 }

  TForm1 = class(TForm)
    BGRAVirtualScreen1: TBGRAVirtualScreen;
    BGRAVirtualScreen2: TBGRAVirtualScreen;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure BGRAVirtualScreen2Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    wallpaper: TBGRABitmap;
    procedure WindowPosChanging(var Msg: TMessage); message WM_WINDOWPOSCHANGED;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
begin
  bitmap.PutImage(-Left, -Top, wallpaper, dmSet);
  Bitmap.Rectangle(0, 0, Bitmap.Width + 1, Bitmap.Height, BGRABlack, dmSet);
end;

procedure TForm1.BGRAVirtualScreen2Redraw(Sender: TObject; Bitmap: TBGRABitmap);
begin
  Bitmap.Rectangle(0, 0, Bitmap.Width, Bitmap.Height, BGRABlack, dmSet);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  wall: string;
  reg: TRegistry;
begin
  wallpaper := TBGRABitmap.Create;
  reg := TRegistry.Create(HKEY_CURRENT_USER);
  if reg.OpenKeyReadOnly('Control Panel\Desktop\') then
  begin
    wall := reg.ReadString('Wallpaper');
    if FileExists(wall) then
    begin
      wallpaper.LoadFromFile(wall);
      BGRAReplace(wallpaper, wallpaper.FilterBlurRadial(BLURSIZE, BLURSIZE, rbBox));
      wallpaper.Rectangle(0, 0, wallpaper.Width, wallpaper.Height,
        BGRA(255, 255, 255, ALPHAVALUE), BGRA(255, 255, 255, ALPHAVALUE), dmDrawWithTransparency);
    end;
  end;
  reg.Free;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  wallpaper.Free;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(Handle, LM_SYSCOMMAND, 61458, 0) ;
end;

procedure TForm1.WindowPosChanging(var Msg: TMessage);
begin
  BGRAVirtualScreen1.DiscardBitmap;
end;

end.
