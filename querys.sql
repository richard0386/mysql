
UUPDATE sales 
SET Numero = CONCAT('6',Numero);
--para agragar id al principio


SELECT Numero,Total
    FROM factura WHERE Numero = '211'
UNION
SELECT NumeroFactura,SUM(Precio)
    FROM detalles WHERE NumeroFactura = '211';
    --union de 2 consultas

    SELECT Numero,Fecha FROM factura WHERE Fecha BETWEEN now() and curdate()
    --selecciona facturas desde fecha de hoy hasta hora actual

    SELECT IF(1<2,'yes','no')
    --if
    SELECT INSERT('Quadratic', 3, 4, 'What');
        -- 'QuWhattic'
        SELECT INSTR('foobarbar', 'bar');
        -- 4

        SELECT LEFT('foobarbar', 5);
        -- 'fooba'
        SELECT LENGTH('text');
        -- 4

        SELECT LOCATE('bar', 'foobarbar');
        -- 4
		SELECT LOWER('QUADRATICALLY');
        -- 'quadratically'

        SELECT LPAD('hi',4,'??');
        -- '??hi'

         SELECT STRCMP('text', 'text2');
        -- -1
         SELECT STRCMP('text2', 'text');
        -- 1
         SELECT STRCMP('text', 'text');
        -- 0

        SELECT UTC_TIMESTAMP()

         SELECT SUBSTRING_INDEX('www.mysql.com', '.', 2);
        -- 'www.mysql'
         SELECT SUBSTRING_INDEX('www.mysql.com', '.', -2);
        -- 'mysql.com'
        CREATE PROCEDURE simpleproc (OUT param1 INT)
SELECT COUNT(*) INTO param1 FROM factura
     --proceddure

     CREATE TRIGGER ins_sum BEFORE INSERT ON factura
       FOR EACH ROW SET @sum = @sum + NEW.Numero;
       --trigger

       START TRANSACTION;
SELECT MAX(Numero) FROM factura;
COMMIT;
--transact

LOCK TABLES factura READ;
SELECT MAX(Numero) FROM factura;
UNLOCK TABLES;
--lock y unlock tablas

--reportes -----------------------------------------------------------------------------------------

SELECT Fecha,Numero,Total,'F' FROM factura
UNION
SELECT Fecha,Numero,Total,'P' FROM sales
--listado

SELECT  items.Barcode AS Codigo,items.Descripcion,items.Marca,
items.Familia,items.Familia,items.Estilo,items.Genero,items.OnHand 
AS Cantidad,items.Precio,(items.OnHand*items.Precio) AS PrecioTotal FROM items
--existencias
----------------------------------------------------------------------------------------------------------------
SELECT saldos.NumFactura,clientes.Nombre,DATEDIFF(curdate(),date(saldos.Fecha)) 
AS Dias_para_vencer,saldos.Inicial AS Monto_del_apartado,(saldos.Inicial-saldos.Saldo)
AS Monto_Cancelado,saldos.Saldo,
IF(saldos.Saldo='0','Totalmente Cancelado',IF(DATEDIFF(curdate(),date(saldos.Fecha))<=90,'Al dia','Vencido')) 
AS Estado FROM saldos,clientes WHERE saldos.CodigoCliente=clientes.Cedula
 --apartados

----------------------------------------------------------------------------------------------------------------
  select Z.nombre,(sum(Z.factura)+sum(Z.sale)+sum(Z.abono)) 
  as Total from (SELECT  v.Nombre,SUM(f.Total) as factura,0 as sale,0 as abono FROM vendedores v 
  	INNER JOIN  factura f ON v.Codigo=f.CodigoVendedor WHERE   f.Tipo='Factura'   AND f.Fecha     
  	BETWEEN '20181201' AND '20181216' GROUP BY v.Nombre union all SELECT v.Nombre,0 as factura,SUM(sales.Total)
  	as sale,0 as abono FROM vendedores v     INNER JOIN sales     ON v.Codigo=sales.CodigoVendedor 
  	WHERE sales.Fecha  BETWEEN '20181201' AND '20181216' GROUP BY v.Nombre 
  	union all  SELECT v.Nombre, 0 as factura ,0 as sale ,SUM(a.Abono) as abono FROM vendedores v   
  	 INNER JOIN  saldos  c  ON v.Codigo=c.CodigoVendedor INNER JOIN abonos a  ON c.NumFactura=a.NumFactura
   where     a.Fecha      BETWEEN '20181201' AND '20181216' GROUP BY v.Nombre )Z  group by Z.Nombre;

  --ventas vendedor
----------------------------------------------------------------------------------------------------------------
  SELECT Fecha,SUM(CASE WHEN T.Consulta = 1 THEN T.Total ELSE 0 END) 
  AS F,SUM(CASE WHEN T.Consulta = 2 THEN T.Total ELSE 0 END) 
  AS P,SUM(CASE WHEN T.Consulta = 3 THEN T.Total ELSE 0 END) 
  AS Abonos,SUM(T.Total) 
  AS Total FROM 
  (SELECT 1 AS Consulta, Date(f.Fecha) as Fecha, SUM(f.Total) 
  	as Total FROM factura f WHERE f.Tipo='Factura' AND f.Fecha 
  	BETWEEN '"+ dateTimePicker1.Value.ToString("yyyy-MM-dd") + "' 
  	AND '"+ dateTimePicker2.Value.ToString("yyyy-MM-dd") + "' GROUP BY Date(f.Fecha)
  	 UNION ALL SELECT 2, Date(s.Fecha), SUM(s.Total) FROM sales s 
  	 WHERE s.Fecha BETWEEN '"+ dateTimePicker1.Value.ToString("yyyy-MM-dd") + "' 
  	 AND '"+ dateTimePicker2.Value.ToString("yyyy-MM-dd") + "' GROUP BY Date(s.Fecha)
  	  UNION ALL SELECT 3, Date(a.Fecha), SUM(a.Abono) FROM abonos a 
  	  WHERE a.Fecha BETWEEN '"+ dateTimePicker1.Value.ToString("yyyy-MM-dd") + "'
  	   AND '" + dateTimePicker2.Value.ToString("yyyy-MM-dd") +"' 
  	GROUP BY Date(a.Fecha)) T GROUP BY T.Fecha ORDER BY T.Fecha
  --ventas diarias

----------------------------------------------------------------------------------------------------------------
SELECT NumeroFactura,
SUM(CASE WHEN C.Consulta=1 THEN C.Total ELSE 0 END) AS Gravados,
SUM(CASE WHEN C.Consulta=2 THEN C.Total ELSE 0 END) AS Excentos,
SUM(CASE WHEN C.Consulta=3 THEN C.Total ELSE 0 END) AS Impuesto
FROM
 (SELECT 1 AS Consulta,NumeroFactura,SUM((Precio*Cantidad-Descuento)/1.13) AS Total
  FROM detalles  
  WHERE Impuesto='(G)' 
  GROUP BY NumeroFactura
 UNION ALL SELECT 2,NumeroFactura,SUM(Precio*Cantidad-Descuento) 
  FROM detalles 
  WHERE Impuesto='(E)' GROUP BY  NumeroFactura
 UNION ALL SELECT 3,NumeroFactura,SUM((Precio*Cantidad-Descuento)-((Precio*Cantidad-Descuento)/1.13))
 FROM detalles
 WHERE Impuesto='(G)'
 GROUP BY NumeroFactura) C 
  GROUP BY C.NumeroFactura ORDER BY C.NumeroFactura
  --Contabilidad constructs


--------------------------------------------------------------------------------------------------------------
  select Z.nombre,(sum(Z.factura)+sum(Z.sale)+sum(Z.abono)) 
  as Total from (SELECT  v.Nombre,SUM(f.Total) as factura,0 as sale,0 as abono FROM vendedores v 
  	INNER JOIN  factura f ON v.Codigo=f.CodigoVendedor WHERE   f.Tipo='Factura'  GROUP BY v.Nombre 
                 union all SELECT v.Nombre,0 as factura,SUM(sales.Total)
  	as sale,0 as abono FROM vendedores v     INNER JOIN sales     ON v.Codigo=sales.CodigoVendedor 
  	 GROUP BY v.Nombre 
  	union all  SELECT v.Nombre, 0 as factura ,0 as sale ,SUM(a.Abono) as abono FROM vendedores v   
  	 INNER JOIN  saldos  c  ON v.Codigo=c.CodigoVendedor INNER JOIN abonos a  ON c.NumFactura=a.NumFactura
    GROUP BY v.Nombre )Z  group by Z.Nombre;

  --ventas vendedor sin fechas
  ----------------------------------------------------------------------------------------------------------------

    SELECT Fecha,SUM(CASE WHEN T.Consulta = 1 THEN T.Total ELSE 0 END) 
  AS F,SUM(CASE WHEN T.Consulta = 2 THEN T.Total ELSE 0 END) 
  AS P,SUM(CASE WHEN T.Consulta = 3 THEN T.Total ELSE 0 END) 
  AS Abonos,SUM(T.Total) 
  AS Total FROM 
  (SELECT 1 AS Consulta, Date(f.Fecha) as Fecha, SUM(f.Total) 
  	as Total FROM factura f WHERE f.Tipo='Factura' GROUP BY Date(f.Fecha)
  	 UNION ALL SELECT 2, Date(s.Fecha), SUM(s.Total) FROM sales s 
  	  GROUP BY Date(s.Fecha)
  	  UNION ALL SELECT 3, Date(a.Fecha), SUM(a.Abono) FROM abonos a 
  	  GROUP BY Date(a.Fecha)) T GROUP BY T.Fecha ORDER BY T.Fecha
  --ventas diarias sin fecha
  ----------------------------------------------------------------------------------------------------------------

  SELECT DATE_ADD('2018-05-01',INTERVAL 90 DAY);
  --agregar dias y obtener la fecha despues de esos dias


  SELECT Fecha,datediff(curdate(),(SELECT Fecha from saldos where NumFactura='118')) 
  AS Dias_paraVencer FROM saldos WHERE NumFactura='118';
  --diferencia de dias entre la fecha actual y una fecha