object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 339
  ClientWidth = 837
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LabelDeviceToken: TLabel
    Left = 416
    Top = 19
    Width = 64
    Height = 13
    Caption = 'Device Token'
  end
  object LabelTitle: TLabel
    Left = 416
    Top = 75
    Width = 20
    Height = 13
    Caption = 'Title'
  end
  object LabelMessage: TLabel
    Left = 416
    Top = 131
    Width = 42
    Height = 13
    Caption = 'Message'
  end
  object ButtonSend: TButton
    Left = 750
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Send'
    TabOrder = 4
    OnClick = ButtonSendClick
  end
  object GroupBoxPlatform: TGroupBox
    Left = 8
    Top = 8
    Width = 377
    Height = 305
    Caption = 'Platform'
    TabOrder = 0
    object LabelAndroidAPIKey: TLabel
      Left = 24
      Top = 224
      Width = 75
      Height = 13
      Caption = 'Android APIKey'
    end
    object LabelAPNSTopic: TLabel
      Left = 24
      Top = 48
      Width = 54
      Height = 13
      Caption = 'APNS Topic'
    end
    object LabelAPNSCertificate: TLabel
      Left = 24
      Top = 94
      Width = 79
      Height = 13
      Caption = 'APNS Certificate'
    end
    object LabelAPNSKey: TLabel
      Left = 24
      Top = 141
      Width = 47
      Height = 13
      Caption = 'APNS Key'
    end
    object RadioButtoniOS: TRadioButton
      Left = 8
      Top = 24
      Width = 113
      Height = 17
      Caption = 'iOS'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = RadioButtoniOSClick
    end
    object RadioButtonAndroid: TRadioButton
      Left = 8
      Top = 199
      Width = 113
      Height = 17
      Caption = 'Android'
      TabOrder = 7
      OnClick = RadioButtonAndroidClick
    end
    object EditAndroidAPIKey: TEdit
      Left = 24
      Top = 243
      Width = 322
      Height = 21
      TabOrder = 6
    end
    object EditAPNSTopic: TEdit
      Left = 24
      Top = 67
      Width = 322
      Height = 21
      TabOrder = 1
      Text = 'com.mycool.app'
    end
    object EditAPNSCertificate: TEdit
      Left = 24
      Top = 112
      Width = 233
      Height = 21
      TabOrder = 2
    end
    object EditAPNSKey: TEdit
      Left = 24
      Top = 160
      Width = 233
      Height = 21
      TabOrder = 4
    end
    object ButtonBrowseCertificate: TButton
      Left = 271
      Top = 110
      Width = 75
      Height = 25
      Caption = 'Browse Cert'
      TabOrder = 3
      OnClick = ButtonBrowseCertificateClick
    end
    object ButtonBrowseKey: TButton
      Left = 271
      Top = 158
      Width = 75
      Height = 25
      Caption = 'Browse Key'
      TabOrder = 5
      OnClick = ButtonBrowseKeyClick
    end
  end
  object EditDeviceToken: TEdit
    Left = 416
    Top = 38
    Width = 409
    Height = 21
    TabOrder = 1
  end
  object EditTitle: TEdit
    Left = 416
    Top = 94
    Width = 409
    Height = 21
    TabOrder = 2
    Text = 'My Title'
  end
  object MemoMessage: TMemo
    Left = 416
    Top = 150
    Width = 409
    Height = 130
    Lines.Strings = (
      'My Message')
    TabOrder = 3
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.pem'
    Left = 336
    Top = 8
  end
end
