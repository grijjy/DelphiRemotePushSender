program DelphiRemotePushSender;

uses
  Vcl.Forms,
  FMain in 'FMain.pas' {FormMain},
  Grijjy.RemotePush.Sender in '..\..\GrijjyFoundation\Grijjy.RemotePush.Sender.pas',
  Grijjy.Bson in '..\..\GrijjyFoundation\Grijjy.Bson.pas',
  Grijjy.Http in '..\..\GrijjyFoundation\Grijjy.Http.pas',
  Grijjy.Http2 in '..\..\GrijjyFoundation\Grijjy.Http2.pas',
  Grijjy.SocketPool.Win in '..\..\GrijjyFoundation\Grijjy.SocketPool.Win.pas',
  Grijjy.Uri in '..\..\GrijjyFoundation\Grijjy.Uri.pas',
  Grijjy.Winsock2 in '..\..\GrijjyFoundation\Grijjy.Winsock2.pas',
  Grijjy.OpenSSL in '..\..\GrijjyFoundation\Grijjy.OpenSSL.pas',
  Grijjy.OpenSSL.API in '..\..\GrijjyFoundation\Grijjy.OpenSSL.API.pas',
  Grijjy.MemoryPool in '..\..\GrijjyFoundation\Grijjy.MemoryPool.pas',
  Grijjy.Collections in '..\..\GrijjyFoundation\Grijjy.Collections.pas',
  Grijjy.BinaryCoding in '..\..\GrijjyFoundation\Grijjy.BinaryCoding.pas',
  Nghttp2 in '..\Nghttp2.pas',
  Grijjy.SysUtils in '..\..\GrijjyFoundation\Grijjy.SysUtils.pas',
  Grijjy.DateUtils in '..\..\GrijjyFoundation\Grijjy.DateUtils.pas',
  Grijjy.Bson.IO in '..\..\GrijjyFoundation\Grijjy.Bson.IO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
