with basis as
-------------------------------------------------------------------------
---------SELECTION UNITSBALANCE PER PRODUCT END OF THE MONTH-------------
(
select ProductKey, 
	   Datekey, 
	   Month, 
	   Year, 
	   Unitsbalance
from (
	select ProductKey,
		   DateKey,
		   MONTH(Movementdate) as Month,
		   YEAR(Movementdate) as Year,
		   Unitsbalance,
		   row_number () over (partition by productkey, YEAR(movementdate), month(movementdate) order by datekey desc) rn
	from AdventureWorksDW2019.dbo.FactProductInventory
	)a
where rn = 1
)
-------------------------------------------------------------------------
---------SELECTION UNITS FLOW PER PRODUCT SUM PER MONTH------------------
,unitflow as
(
select ProductKey, 
	   max(Datekey) as Datekey,
	   sum(UnitsIn) as Sum_unitsin,
	   sum(UnitsOut) as Sum_unitsout
from AdventureWorksDW2019.dbo.FactProductInventory
group by ProductKey, YEAR(movementdate), month(movementdate)
)
-------------------------------------------------------------------------
---------PRODUCT DIMENSION TABLE-----------------------------------------
,productdim AS
(
select ProductKey,
	   EnglishProductName as Product,
	   SafetyStockLevel
from AdventureWorksDW2019.dbo.DimProduct
)
select p.Product,
	   p.SafetyStockLevel,
	   b.Year, 
	   b.Month, 
	   b.Unitsbalance,
	   u.Sum_unitsin,
	   u.Sum_unitsout,
	   case when b.UnitsBalance < p.SafetyStockLevel then 'Below stocklevel threshold' else null end Alert
from basis b
left join unitflow u		on	b.ProductKey = u.ProductKey
							and	b.DateKey = u.DateKey
left join productdim p		on b.ProductKey = p.ProductKey
order by p.Product, b.Year, b.Month 
;