/*

Cleaning Data in SQL Queries

*/


Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


-- Select statement to check the conversion
SELECT SaleDate, DATE(SaleDate) AS ConvertedSaleDate
FROM NashvilleHousing;

-- Update statement to convert and update the SaleDate
UPDATE NashvilleHousing
SET SaleDate = DATE(SaleDate);


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress) AS MergedPropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


UPDATE NashvilleHousing
SET PropertyAddress = COALESCE(
    NashvilleHousing.PropertyAddress,
    (SELECT b.PropertyAddress FROM NashvilleHousing b
     WHERE NashvilleHousing.ParcelID = b.ParcelID AND NashvilleHousing.[UniqueID] <> b.[UniqueID])
)
WHERE NashvilleHousing.PropertyAddress IS NULL;



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NashvilleHousing

SELECT
    SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address,
    SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress)) AS AddressDetails
FROM
    NashvilleHousing;



-- Add a new column PropertySplitAddress to the table
ALTER TABLE NashvilleHousing
ADD COLUMN PropertySplitAddress TEXT;

-- Update statement to set PropertySplitAddress with the substring
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);



-- Add a new column PropertySplitCity to the table
ALTER TABLE NashvilleHousing
ADD COLUMN PropertySplitCity TEXT;

-- Update statement to set PropertySplitCity with the substring
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1);




Select *
From NashvilleHousing



Select OwnerAddress
From NashvilleHousing


SELECT
    SUBSTR(REPLACE(OwnerAddress, ',', '.'), 1, INSTR(REPLACE(OwnerAddress, ',', '.'), '.') - 1) AS Part1,
    SUBSTR(REPLACE(OwnerAddress, ',', '.'), INSTR(REPLACE(OwnerAddress, ',', '.'), '.') + 1) AS Part2,
    NULL AS Part3 
FROM
    NashvilleHousing;



-- Add a new column OwnerSplitAddress to the table
ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitAddress TEXT;

-- Update statement to set OwnerSplitAddress with the parsed value
UPDATE NashvilleHousing
SET OwnerSplitAddress = TRIM(SUBSTR(REPLACE(OwnerAddress, ',', '.'), INSTR(REPLACE(OwnerAddress, ',', '.'), '.') + 1));


-- Add a new column OwnerSplitCity to the table
ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitCity TEXT;

-- Update statement to set OwnerSplitCity with the parsed value
UPDATE NashvilleHousing
SET OwnerSplitCity = TRIM(SUBSTR(REPLACE(OwnerAddress, ',', '.'), INSTR(REPLACE(OwnerAddress, ',', '.'), '.') + 1));




-- Add a new column OwnerSplitState to the table
ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitState TEXT;

-- Update statement to set OwnerSplitState with the parsed value
UPDATE NashvilleHousing
SET OwnerSplitState = TRIM(SUBSTR(REPLACE(OwnerAddress, ',', '.'), 1, INSTR(REPLACE(OwnerAddress, ',', '.'), '.') - 1));




Select *
From NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


-- Create a new table without the columns to be dropped
CREATE TABLE NewNashvilleHousing AS
SELECT
    UniqueID,
    ParcelID,
	LandUse,
	SoldAsVacant,
    SalePrice,
    SaleDate,
    LegalReference,
	OwnerName,
	Acreage,
	LandValue,
	BuildingValue,
	TotalValue,
	YearBuilt,
	Bedrooms,
	FullBath,
	HalfBath,
	PropertySplitAddress,
	PropertySplitCity,
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
	
FROM NashvilleHousing;

-- Drop the original table
DROP TABLE NashvilleHousing;

-- Rename the new table to the original table name
ALTER TABLE NewNashvilleHousing RENAME TO NashvilleHousing;
