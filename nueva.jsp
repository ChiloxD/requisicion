<%-- 
    Document   : nueva
    Created on : 22/06/2016, 02:08:30 PM
    Author     : nunez7
--%>
<%@ page contentType="text/html; charset=utf-8" language="java" import="mx.edu.utdelacosta.*, java.sql.*, java.util.*, java.text.*, java.util.Date" errorPage="" %>
<%
HttpSession sesion = request.getSession();
if(sesion.getAttribute("usuario") == null){
        response.sendRedirect("../login.jsp");
}else{
RequestParamParser parser = new RequestParamParser(request);
int cveModulo = parser.getIntParameter("modulo", 0);
int tab = parser.getIntParameter("tab", 0);

CarearFecha cf = new CarearFecha();
String fechaHoy = cf.hoy();
%>
<form action="" method="post" id="nueva">
    <ol class="miOl">
        <li>
            <label for="fechaNecesita">Fecha en la que se necesita: </label>
            <input type="date" name="fechaNecesita" id="fechaNecesita" value="<%=fechaHoy%>" required/>
        </li>
        <li>
            <label>Proveedor:</label>
        </li>
        <li>
            <label>Nivel de urgencia:</label>
        </li>
        <li>
            <label>Detalle: </label> &nbsp; &nbsp; 
            <br /><br />
            <table>
                <thead>
                    <tr>
                        <th class="centrar">Cantidad</th>
                        <th>Precio ($)</th>
                        <th>Subtotal ($)</th>
                        <th colspan="2">Descripción</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="nuevaColumna"></tbody>
                <tbody id="agregarConcepto">
                    <tr>
                        <td colspan="3"></td>
                        <td colspan="2">
                            <select title="Agregar conceptos" id="listaConceptos">
                                <option value="0">Agregar concepto...</option>
                                <option value="1" data-nombre="Concepto de prueba">Concepto de prueba</option>
                            </select>
                        </td>
                        <td></td>
                    </tr>
                </tbody>
                <tbody>
                    <tr>
                        <td></td>
                        <td><strong>IVA $</strong></td>
                        <td id="calculoIva" class="derecha">00.00</td>
                    </tr>
                </tbody>
                <tbody>
                    <tr>
                        <td></td>
                        <td class="derecha"><strong>Costo total $</strong></td>
                        <td id="totalCosto" class="derecha">00.00</td>
                    </tr>
                </tbody>
            </table>
        </li>
        <li>
            <label>Para ser utilizado en:</label>
            <textarea id="utilEn" placeholder="Lugar donde se usará" name="utilEn" rows="3" cols="50" maxlength="200" required></textarea>
        </li>
        <li>
            <label>Observación:</label>
            <textarea id="observacion" name="observación" rows="3" cols="50" maxlength="200" required>Ninguna</textarea>
        </li>
        <li>
            <label>Cotización:</label>
            <input type="file" name="cotizacion" id="cotizacion" />
        </li>
        <li class="derecha">
            <input type="submit" value="     Enviar     ">
        </li>
    </ol>
</form>
<script>
    $("#listaConceptos").on("change", function () {
        var valor = this.value;
        var nombre = $("#listaConceptos option:selected").data("nombre");
        addConceptoRow(valor, nombre);
    });
    function addConceptoRow(valor, nombre) {
        //Vefificamos la columna
        var trExiste = $("tr#tr_" + valor);

        if (trExiste.length > 0) {
            $("#cant-concepto-req-" + valor).val(($("#cant-concepto-req-" + valor).val() * 1) + 1);
        } else {

            //Agregamos las filas
            if (valor > 0) {
                var tdCantidad = $("<td />",
                        {
                            "class": "centrar",
                            "html": '<input type="number" size="2" onchange="updateTotal();" value="1" min="1" max="10" id="cant-concepto-req-' + valor + '" class="cantidad" >'
                        });
                var tdPrecio = $("<td />",
                        {
                            "text": 100.00,
                            "class": 'derecha',
                            "html": '<input type="text" class="derecha" onchange="updateTotal();" id="precio' + valor + '" size="3" value="100.00" maxlength="9">'

                        });
                var tdSubTotal = $("<td />",
                                    {
                                        "html": '<output class="derecha pu" size="3" id="importe' + valor + '" >100.00</>',
                                        "class": "derecha"
                });         
                var tdDescripcion = $("<td />",
                        {
                            "class": "izquierda",
                            "text": nombre,
                            "colspan": 2
                        });
                var tdEliminar = $("<td />",
                        {
                            "class": "center",
                            "html": '<img src="archivos/delete.png" alt="X" class="imgDelete" onclick="eliminar();" />'
                        });
                var hiddenCveConcepto = $("<input />",
                        {
                            "type": "hidden",
                            "class": "conceptoRequi",
                            "name": "conc-requ-" + valor,
                            "value": valor + "._.1._.100.00._.list",
                            "id": "conc-requ-" + valor
                        });

                var trFila = $("<tr />",
                        {
                            "id": "tr_" + valor,
                            "class": "conceptosRequi"
                        });
                //Añadimos los campos a la fila
                trFila.append(tdCantidad);
                trFila.append(tdPrecio);
                trFila.append(tdSubTotal);
                trFila.append(tdDescripcion);
                trFila.append(tdEliminar);
                trFila.append(hiddenCveConcepto);
                //Añadimos la fila a la tabla
                $("tbody#nuevaColumna").append(trFila);
            }
        }
        $("#listaConceptos option[value=0]").attr("selected", true);
        updateTotal();
    }
    function eliminar()
    {
        $(".imgDelete").parents(':eq(1)').remove();
        updateTotal();
    }
    function updateTotal() {
        var trsAgregador = $("tr.conceptosRequi");
        var totalCobrar = 0.0;
        
        for (var i = 0; i < trsAgregador.length; i++){
             var idTr = ((trsAgregador[i].id).split("_"))[1];
             
             if ($("#conc-requ-" + idTr).length > 0) {
                 var regAgregado = $("#conc-requ-" + idTr).val();
                 var datos = regAgregado.split("._.");
                 
                 var cveConcepto = datos[0];
                 var cantidad = datos[1];
                 var precio = datos[2];
                 var tipo = datos[3];
                 
                 var cantidad = $("#cant-concepto-req-" + idTr).val();
                 var importe = ($("#precio" + idTr).val()) * cantidad;
                 
                 var cadena = cveConcepto+"._."+cantidad+"._."+precio+"._."+tipo;
                 $("#conc-requ-" + idTr).val("" + cadena + "");
                 //Subtotal
                 $("#importe" + idTr).val(importe.toFixed(2));
                 totalCobrar += importe;
             }
        }
        $("#totalCosto").text(totalCobrar.toFixed(2));
        calcularIva(totalCobrar);
    }
    function calcularIva(valor){
        var iva = parseFloat( valor) * .16;
        $("#calculoIva").text(iva.toFixed());
    }
</script>
<%
}
%>