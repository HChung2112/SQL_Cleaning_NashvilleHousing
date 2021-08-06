

--Cleaning data in SQL queries

select *
from PorffolioProject.dbo.Nashvilehousing 

-----------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date format


select SaleDate, CONVERT(date,SaleDate)
from PorffolioProject.dbo.Nashvilehousing 

update Nashvilehousing
set SaleDate = CONVERT(date,SaleDate)


Alter table Nashvilehousing
add SaleDateConverted date;

update Nashvilehousing
set SaleDateConverted = CONVERT(date,saledate)

-----------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

select *
from PorffolioProject.dbo.Nashvilehousing 
--where PropertyAddress is null 
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PorffolioProject.dbo.Nashvilehousing a
join PorffolioProject.dbo.Nashvilehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID] 
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress, 'No Address')
from PorffolioProject.dbo.Nashvilehousing a
join PorffolioProject.dbo.Nashvilehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID] 
where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Indivisual Columns (Address, City, State)


select PropertyAddress
from PorffolioProject.dbo.Nashvilehousing 
--where PropertyAddress is null 
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, len(PropertyAddress)) as ABC

from PorffolioProject.dbo.Nashvilehousing 

alter table Nashvilehousing
add PropertySplitAddress nvarchar(255);

update Nashvilehousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table Nashvilehousing
add PropertySplitCity nvarchar(255);

update Nashvilehousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, len(PropertyAddress))

select OwnerAddress
from PorffolioProject.dbo.Nashvilehousing 


select 
parsename(replace(OwnerAddress, ',', '.'), 3)
, parsename(replace(OwnerAddress, ',', '.'), 2)
, parsename(replace(OwnerAddress, ',', '.'), 1)

from PorffolioProject.dbo.Nashvilehousing 

alter table Nashvilehousing
add OwnerSplitAddress nvarchar(255);

update Nashvilehousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table Nashvilehousing
add OwnerSplitCity nvarchar(255);

update Nashvilehousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)


alter table Nashvilehousing
add OwnerSplitState nvarchar(255);

update Nashvilehousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)


select *
from Nashvilehousing



-----------------------------------------------------------------------------------------------------------------------------------



--Change Y and N to Yes and No in "SoldAsVacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Nashvilehousing
Group by SoldAsVacant
order by 2

Select (SoldAsVacant)
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From Nashvilehousing


Update Nashvilehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End


-----------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates


With RowNumCTE as(
Select *,
	ROW_NUMBER() Over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num

From Nashvilehousing
--Order by ParcelID
)
select *		
From RowNumCTE
where row_num > 1
order by PropertyAddress



--------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

select *
from Nashvilehousing


alter table Nashvilehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, PropertyAddressSplit

alter table Nashvilehousing
drop column SaleDate