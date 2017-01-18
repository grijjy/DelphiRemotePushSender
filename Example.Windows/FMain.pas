unit FMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Grijjy.RemotePush.Sender;

type
  TFormMain = class(TForm)
    ButtonSend: TButton;
    GroupBoxPlatform: TGroupBox;
    RadioButtoniOS: TRadioButton;
    RadioButtonAndroid: TRadioButton;
    EditDeviceToken: TEdit;
    LabelDeviceToken: TLabel;
    EditTitle: TEdit;
    LabelTitle: TLabel;
    LabelMessage: TLabel;
    MemoMessage: TMemo;
    EditAndroidAPIKey: TEdit;
    LabelAndroidAPIKey: TLabel;
    EditAPNSTopic: TEdit;
    LabelAPNSTopic: TLabel;
    EditAPNSCertificate: TEdit;
    LabelAPNSCertificate: TLabel;
    EditAPNSKey: TEdit;
    LabelAPNSKey: TLabel;
    ButtonBrowseCertificate: TButton;
    ButtonBrowseKey: TButton;
    OpenDialog1: TOpenDialog;
    procedure ButtonSendClick(Sender: TObject);
    procedure ButtonBrowseCertificateClick(Sender: TObject);
    procedure ButtonBrowseKeyClick(Sender: TObject);
    procedure RadioButtoniOSClick(Sender: TObject);
    procedure RadioButtonAndroidClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure UpdateControls;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.UpdateControls;
begin
  EditAPNSTopic.Enabled := RadioButtoniOS.Checked;
  EditAPNSCertificate.Enabled := RadioButtoniOS.Checked;
  EditAPNSKey.Enabled := RadioButtoniOS.Checked;
  ButtonBrowseCertificate.Enabled := RadioButtoniOS.Checked;
  ButtonBrowseKey.Enabled := RadioButtoniOS.Checked;
  EditAndroidAPIKey.Enabled := RadioButtonAndroid.Checked;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  UpdateControls;
end;

procedure TFormMain.RadioButtonAndroidClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TFormMain.RadioButtoniOSClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TFormMain.ButtonBrowseCertificateClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    EditAPNSCertificate.Text := OpenDialog1.FileName;
end;

procedure TFormMain.ButtonBrowseKeyClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    EditAPNSKey.Text := OpenDialog1.FileName;
end;

procedure TFormMain.ButtonSendClick(Sender: TObject);
var
  RemotePushSender: TgoRemotePushSender;
  APlatform: TOSVersion.TPlatform;
begin
  RemotePushSender := TgoRemotePushSender.Create;
  try
    if RadioButtoniOS.Checked then
    begin
      APlatform := TOSVersion.TPlatform.pfiOS;
      RemotePushSender.APNSTopic := EditAPNSTopic.Text;
      RemotePushSender.APNSCertificate := TFile.ReadAllBytes(EditAPNSCertificate.Text);
      RemotePushSender.APNSKey := TFile.ReadAllBytes(EditAPNSKey.Text);
    end
    else
    begin
      APlatform := TOSVersion.TPlatform.pfAndroid;
      RemotePushSender.AndroidAPIKey := EditAndroidAPIKey.Text;
    end;
    RemotePushSender.Send(
      APlatform,
      EditDeviceToken.Text,
      EditTitle.Text,
      MemoMessage.Text);
  finally
    RemotePushSender.Free;
  end;
end;

end.
