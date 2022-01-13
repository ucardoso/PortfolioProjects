

--Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------

--Standardize Date Format 

Select SaleDate
From PortfolioProject.dbo.NashvilleHousing   -- It comes with Sale date format with time in the end whihc is not necessary.

Select SaleDate, CONVERT(date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing -- still showing time

Select SaleDateConverted, CONVERT(date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing    --- Worked now

Update NashvilleHousing	
SET SaleDate = CONVERT(date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


--------------------------------------------------------------------------------------------------------------

-- Populate Property Adress data

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null    

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null    --There are lots of Null in areas in ares that it is need a proper information
								 -- in this case it needs to populate some info follwuing the ParcelID

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID                  -- This way is possible to see the same ParcelID with the same ddress but different UniqueID
									-- ex: line 44 and 45 

Select *
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress     -- Organise the together and see where the Nulls are 
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null	                  -- it enables you to see two address and two ParcelIDs columns with Nulls



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]            
Where a.PropertyAddress is null					-- Now when excutes the one above should show empty columns none of the rows has null any more.


---------------------------------------------------------------------------------------------------------------

-- Breaking out Address data 

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing  -- Street name and city together and all separeted by deliminares (coma , )
--Where PropertyAddress is null  
--order by ParcelID 

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing                                 -- it will give the first part of the address before the coma

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address   -- Removing the coma
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing 

----Upadting the Table

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);        --Nvarchar(255) in case is a large string (text)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);        --Nvarchar(255) in case is a large string (text)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))   

--- Execute each query 

Select *
From PortfolioProject.dbo.NashvilleHousing         --- Check on the righ end of the table columns (PropertySplitAddress and PropertySplitCity)


--------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


-- Lets deal with the Owneraddress now USING ANOTHER WAY to separate in columns (EASIER WAY)

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing 

-- Lets use PARSENAME

Select 
PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);       

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);       

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2) 

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);      

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') , 1) 

--- Execute each query 

Select *
From PortfolioProject.dbo.NashvilleHousing         --- Check on the righ end of the table the columns (OwnerSplitAddress, OwnerSplitCity and OwnerSplitState)

-------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field 


Select Distinct (SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing  

-- NUMBER 1
Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing 
Group by SoldAsVacant
Order by 2 

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing     -- 352

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END                       --- AFTER EXECUTING THIS CODE PLEASE DO NUMBER 1 AGAIN TO DOUBLE CHECK.

--------------------------------------------------------------------------------------------------------

-- Remove Duplicates 

Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing   --- row_num will show numbers like 1 and 2 (it means the number of duplicates)

--- to solve it use CTE

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where ROW_NUM > 1
						  --104 duplicates 

-- Lets delete them -- (only needs to add DELETE instead of Select *)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where ROW_NUM > 1    -- All deleted now. Just run the code above to double check.


 -----------------------------------------------------------------------------------------------

 -- Delete Unused Columns      PS. DONT DELETE ANYTHING FROM YOUR RAW DATA

Select *
From PortfolioProject.dbo.NashvilleHousing  

ALTER TABLE PortfolioProject.dbo.NashvilleHousing  
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing  
DROP COLUMN SaleDate


Select *
From PortfolioProject.dbo.NashvilleHousing  