unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellApi, ioutils,
  FileCtrl,
  Vcl.ExtCtrls,
  {��������Ԫ�Ǳ����}
  ComObj, ActiveX, ShlObj;

type
  TForm1 = class(TForm)
    btnRelease: TButton;
    Label1: TLabel;
    Label2: TLabel;
    editUnzipTo: TEdit;
    ComboBoxFileName: TComboBox;
    btnC: TButton;
    btnBrowses: TButton;
    btnAppPath: TButton;
    btnOpen: TButton;
    btnShortLink: TButton;
    procedure btnReleaseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBrowsesClick(Sender: TObject);
    procedure btnCClick(Sender: TObject);
    procedure btnAppPathClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnShortLinkClick(Sender: TObject);
    procedure CreateLink(ProgramPath, ProgramArg, LinkPath, Descr: String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  maxPath = 200; // ��������ַ������鳤��

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnAppPathClick(Sender: TObject);
begin
  editUnzipTo.Text := ExtractFileDir(Application.ExeName);
end;

procedure TForm1.btnBrowsesClick(Sender: TObject);
var
  strPath: string; // �û�ѡ�����Ŀ¼
begin
  strPath := '';
  if (SelectDirectory('Release to...', '', strPath)) then
  begin
    self.editUnzipTo.Text := strPath;
  end;
end;

procedure TForm1.btnCClick(Sender: TObject);
begin
  self.editUnzipTo.Text := 'C:';
end;

procedure TForm1.btnOpenClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'Explorer.exe', PWideChar(editUnzipTo.Text), nil,
    SW_SHOWNORMAL);
end;

procedure TForm1.btnReleaseClick(Sender: TObject);
var
  param: string;
  s: string;
begin
  if ComboBoxFileName.ItemIndex = -1 then
  begin
    ShowMessage('��ѡ��һ����Ч��ѹ������');
    exit;
  end;

  s := ExtractFileName(ComboBoxFileName.Text);
  s := s.Substring(0, s.Length - 4);
  s := self.editUnzipTo.Text + '\' + s;
  param := 'x ' + ComboBoxFileName.Text + ' -o' + s + ' -aoa';
  ShellExecute(0, PWideChar('open'), PWideChar('7z.exe'), PWideChar(param), '',
    SW_SHOWNORMAL); // sw_hide);
end;

procedure TForm1.btnShortLinkClick(Sender: TObject);
var
  exeFileName: string;
  tmp: array [0 .. maxPath] of Char;
  pitem: PITEMIDLIST;
  usrDeskTopPath: string;
  s: string;
  v: string;
begin;
  if ComboBoxFileName.ItemIndex = -1 then
  begin
    ShowMessage('��ѡ��һ����Ч��ѹ������');
    exit;
  end;

  // ����������Ӧ�ó�����
  s := ExtractFileName(ComboBoxFileName.Text);
  s := s.Substring(0, s.Length - 4);
  s := self.editUnzipTo.Text + '\' + s;
  exeFileName := s + '\Teacher\zntbkt.exe';

  // ��ȡ��ǰ�û������λ��
  SHGetSpecialFolderLocation(self.Handle, CSIDL_DESKTOP, pitem);
  setlength(usrDeskTopPath, maxPath);
  shGetPathFromIDList(pitem, PWideChar(usrDeskTopPath));
  usrDeskTopPath := String(PWideChar(usrDeskTopPath));

  v := ExtractFileName(ComboBoxFileName.Text);
  v := v.Substring(0, v.Length - 4);

  CreateLink(exeFileName, // Ӧ�ó�������·��
    '', // ����Ӧ�ó���Ĳ���
    usrDeskTopPath + '\���ܻ�ͬ�����ý�ʦ��' + v + '.lnk', // ��ݷ�ʽ����·��
    '���ܻ�ͬ�����ý�ʦ�ˣ�������Ԫ�󰲿Ƽ����޹�˾��Ȩ����' // ��ע
    );
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  files: TArray<string>;
  i: Integer;
begin
  editUnzipTo.Text := ExtractFileDir(Application.ExeName);
  files := TDirectory.GetFiles(editUnzipTo.Text, '*.zip');
  for i := 0 to Length(files) - 1 do
  begin
    ComboBoxFileName.Items.Add(files[i]);
  end;
end;

procedure TForm1.CreateLink(ProgramPath, ProgramArg, LinkPath, Descr: String);
var
  AnObj: IUnknown;
  ShellLink: IShellLink;
  AFile: IPersistFile;
  FileName: WideString;
begin
  if UpperCase(ExtractFileExt(LinkPath)) <> '.LNK' then // �����չ���Ƿ���ȷ
  begin
    raise Exception.Create('��ݷ�ʽ����չ�������� ���LNK���!');
    // ������������쳣
  end;
  try
    OleInitialize(nil); // ��ʼ��OLE�⣬��ʹ��OLE����ǰ������ó�ʼ��
    AnObj := CreateComObject(CLSID_ShellLink); // ���ݸ�����ClassID����
    // һ��COM���󣬴˴��ǿ�ݷ�ʽ
    ShellLink := AnObj as IShellLink; // ǿ��ת��Ϊ��ݷ�ʽ�ӿ�
    AFile := AnObj as IPersistFile; // ǿ��ת��Ϊ�ļ��ӿ�
    // ���ÿ�ݷ�ʽ���ԣ��˴�ֻ�����˼������õ�����
    ShellLink.SetPath(PChar(ProgramPath)); // ��ݷ�ʽ��Ŀ���ļ���һ��Ϊ��ִ���ļ�
    ShellLink.SetArguments(PChar(ProgramArg)); // Ŀ���ļ�����
    ShellLink.SetWorkingDirectory(PChar(ExtractFilePath(ProgramPath)));
    // Ŀ���ļ��Ĺ���Ŀ¼
    ShellLink.SetDescription(PChar(Descr)); // ��Ŀ���ļ�������
    FileName := LinkPath; // ���ļ���ת��ΪWideString����
    AFile.Save(PWChar(FileName), False); // �����ݷ�ʽ
  finally
    OleUninitialize; // �ر�OLE�⣬�˺���������OleInitialize�ɶԵ���
  end;

end;

end.
