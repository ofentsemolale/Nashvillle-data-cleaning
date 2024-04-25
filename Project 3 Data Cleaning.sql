--Cleaning data in SQL queries
---/*
--------------------------------------------------------------------------------------------------

---Standardize date format
SELECT SaleDateCONVERTED, CONVERT(Date,SaleDate) 
FROM [Nashville housing]


UPDATE [Nashville housing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Nashville housing]
ADD SaleDateCONVERTED Date

UPDATE [Nashville housing]
SET SaleDateCONVERTED = CONVERT(Date,SaleDate)

-------------------------------------------------


---POPULATE THE PROPERTY ADDRESS
SELECT *
FROM [Nashville housing]
--WHERE PropertyAddress is null
ORDER BY ParcelID

--- A JOIN function was used to join the exact table to itself
--but the ParcelID is the same but a different row, so its similar to removing duplicates
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville housing] a
JOIN [Nashville housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville housing] a
JOIN [Nashville housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------


---Breaking out address individua into coloumns (City, State, Address)
SELECT PropertyAddress
FROM [Nashville housing]
--WHERE PropertyAddress is null
--ORDER BY ParcelID


---This line of code is to remove the Commas on the propertyaddress, 
--which is why CHARINDEX is used, the number -1 is used as a backspace
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress )-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress)) as Address
FROM [Nashville housing]


--- I updated the table and added a seperate column name for cities and address
--- These functions below were used to make the query possible
ALTER TABLE [Nashville housing]
ADD PropertysplitAdress Nvarchar(255);

UPDATE [Nashville housing]
SET PropertysplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress )-1) 


ALTER TABLE [Nashville housing]
ADD PropertSplitCity Nvarchar(255);

UPDATE [Nashville housing]
SET PropertSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress))

SELECT *
FROM [Nashville housing]


---This was to seperate the data in a much simple and faster way by using PARSENAME (Seperating the commas and periods)
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) ,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM [Nashville housing]


---This is to add/update the table with new column info
ALTER TABLE [Nashville housing]
ADD OwnersplitAdress Nvarchar(255);

UPDATE [Nashville housing]
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE [Nashville housing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Nashville housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE [Nashville housing]
ADD OwnerSplitState Nvarchar (255);

UPDATE [Nashville housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [Nashville housing]

----------------------------------------------------------------------

---Remove dupilcates
--CTE is used here and WINDOWS function

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 ) ROW_NUMBER
FROM [Nashville housing]
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUMBER > 1
ORDER  BY PropertyAddress

-------------------------------------------------------------


---Delete unused colomuns
SELECT *
FROM [Nashville housing]

ALTER TABLE [Nashville housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM [Nashville housing]

ALTER TABLE [Nashville housing]
DROP COLUMN SaleDate

------------------------------------------------------------------------

---- Change Y and N to Yes and No in "Sold as Vacant" field

--CASE WHEN is a common factor here as it is used to filter the results of
--An UPDATE SET  Function is used here to fix the Y and N to Yes and No
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville housing]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 
FROM [Nashville housing]

UPDATE [Nashville housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 