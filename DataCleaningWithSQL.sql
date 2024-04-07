/*       DATA CLEANING      */

-- Cleanin Data in SQL queries
SELECT *
FROM PortFolioProject.dbo.NashvilleHousing
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(date, SaleDate) DATES
FROM PortFolioProject.dbo.NashvilleHousing

UPDATE PortFolioProject..NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date

UPDATE NashvilleHousing
SET SalEDateConverted = CONVERT(date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT * --PropertyAddress
FROM PortFolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) UPDATED
FROM PortFolioProject..NashvilleHousing a
JOIN PortFolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortFolioProject..NashvilleHousing a
JOIN PortFolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns(Address, City, State)


SELECT PropertyAddress
FROM PortFolioProject..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) Address
FROM PortFolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT *
FROM PortFolioProject..NashvilleHousing



SELECT OwnerAddress
FROM PortFolioProject..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortFolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) COUN
FROM PortFolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Yes' THEN 'Y'
		WHEN SoldAsVacant = 'No' THEN 'N'
		ELSE SoldAsVacant
	END
FROM PortFolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE 
		WHEN SoldAsVacant = 'Yes' THEN 'Y'
		WHEN SoldAsVacant = 'No' THEN 'N'
		ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, 
								PropertyAddress, 
								SalePrice, 
								SaleDate, 
								LegalReference
								ORDER BY UniqueID
								) rowNum

FROM PortFolioProject..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE rowNum > 1
ORDER BY PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns


SELECT * 
FROM PortFolioProject..NashvilleHousing

ALTER TABLE PortFolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortFolioProject..NashvilleHousing
DROP COLUMN SaleDate



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

