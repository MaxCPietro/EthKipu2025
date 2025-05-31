// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SubastaScroll {
    //DEFINICION DE VARIABLES
    //1.1 - variables de estado
    address public propietario;
    uint public finSubasta;
    bool public finalizada;

    //1.2 - Clase
    struct Oferta {
        address ofertante;
        uint monto;
    }

    //1-3 variables de Oferta
    Oferta public mejorOferta;
    Oferta[] public listaOfertas;
    mapping (address => uint) public deposito;

    //1.4 - comisión fija 
    uint public costoComision = 2;

    //2. DEFINICIÓN DE EVENTOS
    event nuevaOferta(address oferante, uint monto);
    event subastaFinalizada (address ganador, uint monto);

    //3. MODIFICADORES
    //.3.1 Esta funcion solo puede ser ejecutada por el owner
    modifier verificarPropietarioMod() {
        require (msg.sender == propietario, "No tienes los privilegios necesarios");  // Requiere el token de la tarea
        _;   }
    
    //3.2 Que la subasta este abuerta (ya sea por tiempo o porque no fue cerrada a mano)
    modifier subastaAbiertaMod() {
        require(block.timestamp < finSubasta, "La subasta ya ha finalizado");
        require(!finalizada, "La subasta finalizada");
        _;
    }

    //3.3 Subasta Finalizada
    modifier subastaFinalizadaMod() {
        require(block.timestamp >= finSubasta || finalizada, "La subasta no ha sido cerrada");
        _;
    } 

    //4-CONSTRUCTOR
    constructor(uint _duracionInicialSegundos) {
        propietario= msg.sender;
        finSubasta = block.timestamp + _duracionInicialSegundos;
        mejorOferta = Oferta(address(0), 0);
        finalizada = false;
    }

    //5-FUNCIONES
    //5.1 - Función Ofertar
    function ofertar () external payable subastaAbiertaMod {
        require(msg.value > 0, "Debes enviar ETH");

        uint _incrementoMinimo = (mejorOferta.monto * 105)/100;

        //inicializo con la primera oferta
        if (mejorOferta.monto == 0) {
            _incrementoMinimo = 1;
        }
        
        //Verifico que sea un 5% mas alto
        require (msg.value >= _incrementoMinimo, "la oferta debe superar al menos un 5% de la actual");

        //Guardo la oferta
        deposito[msg.sender] += msg.value;
        mejorOferta = Oferta(msg.sender, msg.value);

        //guardo en el array el historial
        listaOfertas.push(mejorOferta);

        //Si faltan menos de 10 min le sumo 10 min mas
        if (finSubasta - block.timestamp <= 10 minutes) {
            finSubasta += 10 minutes;
        }

        //llamo al evento de volver a ofertar
        emit nuevaOferta(msg.sender, msg.value);

    }

    //5.2 - Función retirarExceso
    function retirarExceso() external subastaAbiertaMod {
        uint ultimaOferta = (msg.sender == mejorOferta.ofertante) ? mejorOferta.monto : 0;
        uint exceso = deposito[msg.sender] - ultimaOferta;
        require(exceso > 0, "No hay exceso para retirar");

        deposito[msg.sender] -= exceso;
        payable(msg.sender).transfer(exceso);
    }


    //5.3 - funcion devolverDepositos
    function devolverDepositos() external subastaFinalizadaMod {
        require(msg.sender != mejorOferta.ofertante, "El ganador no recibe reembolso");

        uint _monto = deposito[msg.sender];
        require(_monto >0, "No hay nada para devolver");

        uint _comision = (_monto * costoComision) / 100;

        uint _reembolso = _monto - _comision;

        deposito[msg.sender] = 0;
        payable(msg.sender).transfer(_reembolso);
    }

    //5.4 - función finalizarSubasta
    function finalizarSubasta() external verificarPropietarioMod subastaFinalizadaMod {}

    //5.5 - Función verGanador()
    function verGanador() external view subastaFinalizadaMod returns(address,uint){
        return (mejorOferta.ofertante, mejorOferta.monto);
    } 

    //5.6 - Función verHistorial()
   function verHistorial() external view returns (Oferta[] memory) {
        return listaOfertas;
    }


}