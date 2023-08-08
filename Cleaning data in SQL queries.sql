--Cleaning data in SQL queries


--Select SaleDateConverted, CONVERT(date, SaleDate)
--FROM cvproject..Nashvillehousing


UPDATE cvproject..Nashvillehousing
SET SaleDate = CONVERT(date, SaleDate)


--ALTER table cvproject..Nashvillehousing
--ADD SaleDateConverted Date 

--UPDATE cvproject..Nashvillehousing
--SET SaleDateConverted = CONVERT(date, SaleDate)

--Populate Properyty Address data

Select *
FROM cvproject..Nashvillehousing
--where PropertyAddress is NULL
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM cvproject..Nashvillehousing a 
JOIN cvproject..Nashvillehousing b
    on a.ParcelID = b.ParcelID
    And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM cvproject..Nashvillehousing a 
JOIN cvproject..Nashvillehousing b
    on a.ParcelID = b.ParcelID
    And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


--breaking out Address into Indivindual Colums (Adress City, State)

Select PropertyAddress
FROM cvproject..Nashvillehousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM cvproject..Nashvillehousing


ALTER table cvproject..Nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

--UPDATE cvproject..Nashvillehousing
--SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
--
--ALTER table cvproject..Nashvillehousing
--ADD PropertySplitCity NVARCHAR(255);
--
--UPDATE cvproject..Nashvillehousing
--SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM cvproject..Nashvillehousing




SELECT OwnerAddress
FROM cvproject..Nashvillehousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM cvproject..Nashvillehousing
--
--
--ALTER table cvproject..Nashvillehousing
--ADD OwnerSplitAddress NVARCHAR(255);
--
--UPDATE cvproject..Nashvillehousing
--SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
--
--ALTER table cvproject..Nashvillehousing
--ADD OwnerSplitCity NVARCHAR(255);
--
--UPDATE cvproject..Nashvillehousing
--SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
--
--ALTER table cvproject..Nashvillehousing
--ADD OwnerSplitState NVARCHAR(255);
--
--UPDATE cvproject..Nashvillehousing
--SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--
--
SELECT *
FROM cvproject..Nashvillehousing



-- change Y and N to yes and No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant) , COUNT(SoldAsVacant)
from cvproject..Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       ELSE SoldAsVacant 
       END
from cvproject..Nashvillehousing


Update cvproject..Nashvillehousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       ELSE SoldAsVacant 
       END

--remove duplicates


--CTE (temp table)
WITH RowNumCTE AS(
Select *
, ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
               SalePrice,
               SaleDate,
               LegalReference
               ORDER BY 
               UniqueID
) row_num
from cvproject..Nashvillehousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
where row_num >1
ORDER BY PropertyAddress


--Delete unused Columns
SELECT *
FROM cvproject..Nashvillehousing

ALTER Table cvproject..Nashvillehousing
drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




