SELECT *
FROM Nashville

-- STANDARDIZE DATE FORMAT

SELECT SaleDateConvert, CONVERT(DATE, SaleDate)
FROM Nashville

UPDATE Nashville
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE Nashville
add SaleDateConvert Date

UPDATE Nashville
SET SaleDateConvert = CONVERT(DATE,SaleDate)


--POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM Nashville
WHERE PropertyAddress is Null
--Property address which is null has parcelID, which each parcelID has an address. We can then match
-- each property address with parcelID and populate the ones which is null


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Nashville A
INNER JOIN Nashville B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Nashville A
INNER JOIN Nashville B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) AS Address
FROM Nashville
--DON'T INCLUDE COMMA


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS City

FROM Nashville


ALTER TABLE Nashville
add PropertySplitAddress nvarchar(255)

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville
add PropertySplitCity nvarchar(255)

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM Nashville


ALTER TABLE Nashville
add OwnerSplitAddress nvarchar(255)

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE Nashville
add OwnerSplitCity nvarchar(255)

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE Nashville
add OwnerSplitState nvarchar(255)

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and NO in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM Nashville

UPDATE Nashville
SET SoldAsVacant =
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END



--Remove Duplicates


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Nashville
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Columns


ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Nashville
DROP COLUMN SaleDate

SELECT *
FROM Nashville