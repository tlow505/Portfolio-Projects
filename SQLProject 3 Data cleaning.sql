-- Data cleaning 

SELECT *
FROM NashvileHousing


------------------------------------------------------------------------------------------------------------------------------

-- Standardize SaleDate and reformat it

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvileHousing


ALTER TABLE NashvileHousing
ADD SaleDateConverted Date;

UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT *
FROM NashvileHousing


------------------------------------------------------------------------------------------------------------------------------

-- Fill Property Address data

SELECT *
FROM NashvileHousing
--WHERE PropertyAddress IS NULL
order by ParcelID

/* Replaced Missing property address by using parcelID. If there are Property address with the same ParcelID's, but only 1 of the property address is filled in, we can just copy that address over to fill in the null
*/

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvileHousing a
INNER JOIN NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvileHousing a
INNER JOIN NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------------------------------

-- Break Address into individual columns ( Address, City, State )

-- Begin breaking up PropertyAddress
SELECT PropertyAddress
FROM NashvileHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE NashvileHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

select *
FROM NashvileHousing

-- Now we are going to break up OwnerAddress

SELECT OwnerAddress
FROM NashvileHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvileHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvileHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvileHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

SELECT SoldAsVacant, count(SoldAsVacant)
FROM NashvileHousing
group by SoldAsVacant

------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates
-- I Shouldnt delete data here , but since this a showcase project im going to ignore that practice to make cleaning a bit easier.

WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM NashvileHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1




------------------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns


SELECT *
FROM NashvileHousing

ALTER TABLE NashvileHousing
DROP COLUMN PropertyAddress,OwnerAddress, TaxDistrict, SaleDate

