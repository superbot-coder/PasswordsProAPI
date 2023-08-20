object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'HASH TESTER (PasswordsPro API) '
  ClientHeight = 797
  ClientWidth = 822
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    822
    797)
  PixelsPerInch = 96
  TextHeight = 13
  object LblSelectAlgo: TLabel
    Left = 16
    Top = 18
    Width = 159
    Height = 13
    Caption = #1042#1099#1073#1086#1088' '#1072#1083#1075#1086#1088#1080#1090#1084#1072' (select algos):'
  end
  object LblHashSize: TLabel
    Left = 536
    Top = 78
    Width = 67
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1093#1101#1096#1072':'
  end
  object CmBoxSelectAlgo: TComboBox
    Left = 8
    Top = 37
    Width = 336
    Height = 21
    Style = csDropDownList
    DropDownCount = 30
    TabOrder = 0
    OnSelect = CmBoxSelectAlgoSelect
  end
  object mm: TMemo
    Left = 0
    Top = 136
    Width = 822
    Height = 636
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    OEMConvert = True
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object BtnGetHash: TButton
    Left = 625
    Top = 95
    Width = 122
    Height = 25
    Caption = #1055#1054#1051#1059#1063#1048#1058#1068' HASH'
    TabOrder = 2
    OnClick = BtnGetHashClick
  end
  object lblEditPassword: TLabeledEdit
    Left = 16
    Top = 97
    Width = 160
    Height = 21
    EditLabel.Width = 98
    EditLabel.Height = 13
    EditLabel.Caption = #1055#1072#1088#1086#1083#1100' (Password):'
    TabOrder = 3
  end
  object lblEditUserName: TLabeledEdit
    Left = 192
    Top = 97
    Width = 160
    Height = 21
    EditLabel.Width = 157
    EditLabel.Height = 13
    EditLabel.Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' (UserName):'
    TabOrder = 4
  end
  object lblEditSalt: TLabeledEdit
    Left = 368
    Top = 97
    Width = 160
    Height = 21
    EditLabel.Width = 58
    EditLabel.Height = 13
    EditLabel.Caption = #1057#1086#1083#1100' (Salt):'
    TabOrder = 5
  end
  object SpEditHashSize: TSpinEdit
    Left = 536
    Top = 97
    Width = 67
    Height = 22
    MaxLength = 4
    MaxValue = 512
    MinValue = 2
    TabOrder = 6
    Value = 16
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 778
    Width = 822
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitLeft = 328
    ExplicitTop = 768
    ExplicitWidth = 0
  end
  object ChBoxLoverHash: TCheckBox
    Left = 368
    Top = 39
    Width = 193
    Height = 17
    Caption = #1042#1099#1074#1086#1076#1080#1090#1100' '#1093#1101#1096' '#1074' '#1085#1080#1078#1085#1077#1084' '#1088#1077#1075#1080#1089#1090#1088#1077
    TabOrder = 8
  end
  object MainMenu: TMainMenu
    Left = 560
    Top = 192
    object N1: TMenuItem
      Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103
      object MM_AboutView: TMenuItem
        Caption = #1054' '#1084#1086#1076#1091#1083#1077
        OnClick = MM_AboutViewClick
      end
      object MM_ViewFlagsInfo: TMenuItem
        Caption = #1054' '#1092#1083#1072#1075#1072#1093' '#1084#1086#1076#1091#1083#1103
        OnClick = MM_ViewFlagsInfoClick
      end
      object MM_Test: TMenuItem
        Caption = 'TEST'
        Visible = False
        OnClick = MM_TestClick
      end
    end
    object B1: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object MMOpenProjectGitHub: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1089#1090#1088#1072#1085#1080#1094#1091' '#1087#1088#1086#1077#1082#1090#1072' '#1085#1072' GitHub'
        OnClick = MMOpenProjectGitHubClick
      end
      object MMOpenGitHubOverView: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1075#1083#1072#1074#1085#1091#1102' '#1089#1090#1088#1072#1085#1080#1094#1091' '#1085#1072' GitHub'
        OnClick = MMOpenGitHubOverViewClick
      end
    end
  end
end
