/*
Cleaning Data in SQL
*/

SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


--Standardizing the Date Format

SELECT Saledateconverted, CONVERT(date, saledate)
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


  Update Nashvillehousing
  Set SaleDate= CONVERT(date, saledate)

  Alter table Nashvillehousing
  Add Saledateconverted Date;
  
  Update Nashvillehousing
  Set Saledateconverted = CONVERT(date, saledate)


--populate property address data
SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  --where propertyaddress is null
  order by parcelID

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(A.propertyaddress, b.propertyaddress) 
  FROM [PortfolioProject].[dbo].[NashvilleHousing] a
  Join [PortfolioProject].[dbo].[NashvilleHousing] b
  on a.parcelid=b.parcelid
  and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
SET propertyaddress = ISNULL(A.propertyaddress, b.propertyaddress)  
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
  Join [PortfolioProject].[dbo].[NashvilleHousing] b
  on a.parcelid=b.parcelid
  and a.uniqueid <> b.uniqueid
  where a.propertyaddress is null

--Turning Address into Individual Columns (Address, City, State)
SELECT propertyaddress
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  --where propertyaddress is null
  --order by parcelID

-- Using Substring function
Select
Substring(propertyaddress, 1, charindex(',', propertyaddress)-1) as Address,  --Going to the comma, and subtracting it with -1
Substring(propertyaddress, charindex(',', propertyaddress)+1 , Len(propertyaddress)) as Address
FROM [PortfolioProject].[dbo].[NashvilleHousing]

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);
  
Update [PortfolioProject].[dbo].[NashvilleHousing]
Set PropertySplitAddress = Substring(propertyaddress, 1, charindex(',', propertyaddress)-1)

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitCity Nvarchar(255);
  
Update [PortfolioProject].[dbo].[NashvilleHousing]
Set PropertySplitCity = Substring(propertyaddress, charindex(',', propertyaddress)+1 , Len(propertyaddress))

Select *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

--Using Parsename Function

Select Owneraddress
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

Select
Parsename(Replace(OwnerAddress, ',', '.'),3),
Parsename(Replace(OwnerAddress, ',', '.'),2),
Parsename(Replace(OwnerAddress, ',', '.'),1)
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  where OwnerAddress is not null 

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);
  
Update [PortfolioProject].[dbo].[NashvilleHousing]
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'),3)

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);
  
Update [PortfolioProject].[dbo].[NashvilleHousing]
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'),2)

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add Owndersplitstate Nvarchar(255);
  
Update [PortfolioProject].[dbo].[NashvilleHousing]
Set Owndersplitstate = Parsename(Replace(OwnerAddress, ',', '.'),1)


--Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(Soldasvacant), count (Soldasvacant)
FROM [PortfolioProject].[dbo].[NashvilleHousing]
group by soldasvacant
order by 2

Select soldasvacant,
	Case when soldasvacant = 'Y' Then 'Yes' 
	When SOldasvacant = 'N' Then 'No'
	Else Soldasvacant
	End
FROM [PortfolioProject].[dbo].[NashvilleHousing]

Update [PortfolioProject].[dbo].[NashvilleHousing]
Set soldasvacant = Case when soldasvacant = 'Y' Then 'Yes' 
	When SOldasvacant = 'N' Then 'No'
	Else Soldasvacant
	End 

--Remove Duplicates

With RowNumCTE AS (
Select *,
Row_number() Over(
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 Saledate,
			 legalreference
			 Order by
				UniqueID
				)row_num
FROM [PortfolioProject].[dbo].[NashvilleHousing]
)

Delete
FROM RowNUMCTE
where row_num>1


--Delete Unused Columns
Select *
FROM [PortfolioProject].[dbo].[NashvilleHousing]

Alter Table [PortfolioProject].[dbo].[NashvilleHousing]
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table [PortfolioProject].[dbo].[NashvilleHousing]
Drop Column Saledate