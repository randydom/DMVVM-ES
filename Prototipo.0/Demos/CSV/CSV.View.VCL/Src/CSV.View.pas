unit CSV.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList,

  MVVM.Interfaces,
  CSV.Interfaces;

type
  TfrmCSV = class(TForm, ICSVFile_View)
    lePath: TLabeledEdit;
    btPath: TButton;
    mmInfo: TMemo;
    btTNP: TButton;
    btTP: TButton;
    FileOpenDialog1: TFileOpenDialog;
    btNuevaVista: TButton;
    ActionList1: TActionList;
    DoCrearVista: TAction;
    DoSelectFile: TAction;
    procedure btTNPClick(Sender: TObject);
    procedure btTPClick(Sender: TObject);
    procedure DoCrearVistaExecute(Sender: TObject);
    procedure DoSelectFileExecute(Sender: TObject);
    procedure lePathChange(Sender: TObject);
  private
    { Private declarations }
    FViewModel: ICSVFile_ViewModel;
  protected
    procedure OnProcesoFinalizado(const ADato: String);

    procedure DoSeleccionarFichero;
    procedure DoCrearNuevaVista;
    procedure DoMetodoNoParalelo;
    procedure DoMetodoParalelo;
  public
    { Public declarations }
    procedure AddViewModel(AViewModel: IViewModel<ICSVFile_Model>);
    procedure RemoveViewModel(AViewModel: IViewModel<ICSVFile_Model>);
  end;

var
  frmCSV: TfrmCSV;

implementation

uses
  Spring;

{$R *.dfm}

{ TForm1 }

procedure TfrmCSV.AddViewModel(AViewModel: IViewModel<ICSVFile_Model>);
begin
  if FViewModel <> AViewModel then
  begin
    if Supports(AViewModel, ICSVFile_ViewModel, FViewModel)  then
    begin
      FViewModel := AViewModel as ICSVFile_ViewModel;
      //Bindings a capela
      //1) boton ejecución no paralela
      FViewModel.Bind('src', '"Test-No Parallel, File: " + src.FileName', btTNP, 'dst', 'dst.Caption'); //formateo del caption
      FViewModel.Bind('IsValidFile', btTNP, 'Enabled'); //boton habilitado o no
      //2) boton ejecución en paralelo
      FViewModel.Bind('src', '"Test-Parallel, File: " + src.FileName', btTP, 'dst', 'dst.Caption'); //formateo del caption
      FViewModel.Bind('IsValidFile', btTP, 'Enabled'); //boton habilitado o no
      //3) evento de fin de procesamiento
      FViewModel.OnProcesamientoFinalizado.Add(OnProcesoFinalizado);
    end
    else raise Exception.Create('No casan las interfaces');
  end;
end;

procedure TfrmCSV.btTNPClick(Sender: TObject);
begin
  DoMetodoNoParalelo;
end;

procedure TfrmCSV.btTPClick(Sender: TObject);
begin
  DoMetodoParalelo;
end;

procedure TfrmCSV.DoCrearNuevaVista;
var
  LVista: TfrmCSV;
begin
  Guard.CheckNotNull(FViewModel, 'ViewModel no asignado');
  LVista := TfrmCSV.Create(Self);
  LVista.AddViewModel(FViewModel);
  LVista.Show;
end;

procedure TfrmCSV.DoCrearVistaExecute(Sender: TObject);
begin
  DoCrearNuevaVista
end;

procedure TfrmCSV.DoMetodoNoParalelo;
begin
  Guard.CheckNotNull(FViewModel, 'ViewModel no asignado');
  if not FViewModel.ProcesarFicheroCSV then
    mmInfo.Lines.Add('Hay problemas')
  else mmInfo.Lines.Add('Ok')
end;

procedure TfrmCSV.DoMetodoParalelo;
begin
  Guard.CheckNotNull(FViewModel, 'ViewModel no asignado');
  if not FViewModel.ProcesarFicheroCSV_Parallel then
    mmInfo.Lines.Add('Hay problemas')
  else mmInfo.Lines.Add('Ok')
end;

procedure TfrmCSV.DoSeleccionarFichero;
begin
 if not String(lePath.Text).IsEmpty then
  begin
    FileOpenDialog1.FileName := lePath.Text;
  end;
  if FileOpenDialog1.Execute then
  begin
    lePath.Text := FileOpenDialog1.FileName;
  end;
end;

procedure TfrmCSV.DoSelectFileExecute(Sender: TObject);
begin
  DoSeleccionarFichero
end;

procedure TfrmCSV.lePathChange(Sender: TObject);
begin
  Guard.CheckNotNull(FViewModel, 'ViewModel no asignado');
  FViewModel.FileName := lePath.Text;
end;

procedure TfrmCSV.OnProcesoFinalizado(const ADato: String);
begin
  mmInfo.Lines.Add('Evento fin procesamiento: ' + ADato)
end;

procedure TfrmCSV.RemoveViewModel(AViewModel: IViewModel<ICSVFile_Model>);
begin
  FViewModel := nil;
end;

end.
