unit Venda.Model;

interface

uses
  Venda.Model.Inerf,
  Cliente.Model.Interf,
  Item.Model.Interf,
  Pagamento.Model.Interf,
  Entidade_Venda.Model,
  ormbr.container.objectset.interfaces,
  Conexao.Model.Interf,
  Caixa.Model.interf,
  Fiscal.Model.Interf,
  Empresa.Model.Interf;

type
  TVendaModel = class(TInterfacedObject, IVendaModel, IVendaMetodoModel)
  private
    FConn: IConexaoModel;
    FEntidade: TVENDA;
    FDAO: IContainerObjectSet<TVENDA>;
    FState: IVendaMetodoModel;
    FModalidadeFiscal: IFIscalModel;
    FCaixa: ICaixaModel;
    FCliente: IClienteModel;
    FItens: IItemModel;
    FPagamentos: IPagamentoModel;
    FEmpresa: IEmpresaModel;
    FObservers: IVendaObserverModel;
  public
    constructor Create(Caixa: ICaixaModel);
    destructor Destroy; override;
    class function New(Caixa: ICaixaModel): IVendaModel;

    // VendaModel
    function Metodo: IVendaMetodoModel;
    function SetState(Value: IVendaMetodoModel): IVendaMetodoModel;
    function Caixa: ICaixaModel;
    function Empresa: IEmpresaModel;
    function Cliente: IClienteModel; overload;
    function Cliente(Value: IClienteModel): IVendaModel; overload;
    function Itens: IItemModel;
    function Pagamentos: IPagamentoModel;
    function Entidade: TVENDA; overload;
    function Entidade(Value: TVENDA): IVendaModel; overload;
    function DAO: IContainerObjectSet<TVENDA>;
    function ModalidadeFiscal(Value: IFiscalModel): IVendaModel; overload;
    function ModalidadeFiscal: IFiscalModel; overload;
    function Observers: IVendaObserverModel;

    // VendaMetodoModel
    function Abrir: IVendaMetodoAbrirModel;
    function Pagar: IVendaMetodoPagarModel;
    function Fechar: IVendaMetodoFecharModel;
    function &End: IVendaModel;
  end;

implementation

uses
  Venda_Metodo_Factory.Model,
  Venda_State_Factory.Model,
  PDVUpdates.Model,
  ormbr.container.objectset, Venda_Observer.Model;

{ TVendaModel }

function TVendaModel.Abrir: IVendaMetodoAbrirModel;
begin
  FState.Abrir;
  Result := TVendaMetodoFactoryModel.New.Abrir(Self);
end;

function TVendaModel.Empresa: IEmpresaModel;
begin
  Result := FEmpresa;
end;

function TVendaModel.&End: IVendaModel;
begin
  Result := Self;
end;

function TVendaModel.Entidade: TVENDA;
begin
  Result := FEntidade;
end;

function TVendaModel.Entidade(Value: TVENDA): IVendaModel;
begin
  Result := Self;
  FEntidade := Value;
end;

function TVendaModel.Cliente: IClienteModel;
begin
  Result := FCliente;
end;

function TVendaModel.Caixa: ICaixaModel;
begin
  Result := FCaixa;
end;

function TVendaModel.Cliente(Value: IClienteModel): IVendaModel;
var
  VENDA: TVENDA;
begin
  Result := Self;
  FCliente := Value;

  VENDA := FEntidade;
  FDAO.Modify(VENDA);
  VENDA.CLIENTE := FCliente.Entidade.GUUID;
  FDAO.Update(VENDA);
end;

constructor TVendaModel.Create(Caixa: ICaixaModel);
begin
  FCaixa      := Caixa;
  FConn       := TPDVUpdatesModel.New.Conexao;
  FEntidade   := TPDVUpdatesModel.New.Entidade.Venda;
  FDAO        := TContainerObjectSet<TVenda>.Create(FConn.Connection, 15);
  FState      := TVendaStateFactoryModel.New.Fechado;
  FModalidadeFiscal := TPDVUpdatesModel.New.Fiscal;
  FCliente    := TPDVUpdatesModel.New.Cliente;
  FItens      := TPDVUpdatesModel.New.Item(Self);
  FPagamentos := TPDVUpdatesModel.New.Pagamento(Self);
  FEmpresa    := TPDVUpdatesModel.New.Empresa;
  FObservers  := TVendaObserverModel.New(Self);
end;

function TVendaModel.DAO: IContainerObjectSet<TVENDA>;
begin
  Result := FDAO;
end;

destructor TVendaModel.Destroy;
begin

  inherited;
end;

function TVendaModel.Fechar: IVendaMetodoFecharModel;
begin
  FState.Fechar;
  Result := TVendaMetodoFactoryModel.New.Fechar(Self);
end;

function TVendaModel.Itens: IItemModel;
begin
  Result := FItens;
end;

function TVendaModel.Metodo: IVendaMetodoModel;
begin
  Result := Self;
end;

function TVendaModel.ModalidadeFiscal(Value: IFiscalModel): IVendaModel;
begin
  Result := Self;
  FModalidadeFiscal := Value;
end;

function TVendaModel.ModalidadeFiscal: IFiscalModel;
begin
  Result := FModalidadeFiscal;
end;

class function TVendaModel.New(Caixa: ICaixaModel): IVendaModel;
begin
  Result := Self.Create(Caixa);
end;

function TVendaModel.Observers: IVendaObserverModel;
begin
  Result := FObservers;
end;

function TVendaModel.Pagamentos: IPagamentoModel;
begin
  Result := FPagamentos;
end;

function TVendaModel.Pagar: IVendaMetodoPagarModel;
begin
  FState.Pagar;
  Result := TVendaMetodoFactoryModel.New.Pagar(Self);
end;

function TVendaModel.SetState(Value: IVendaMetodoModel): IVendaMetodoModel;
begin
  Result := Self;
  FState := Value;
end;

end.
