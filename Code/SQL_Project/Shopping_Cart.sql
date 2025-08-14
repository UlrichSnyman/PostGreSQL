DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS OrderHeader;
DROP TABLE IF EXISTS Cart;
DROP TABLE IF EXISTS ProductsMenu;
DROP TABLE IF EXISTS Users;

SELECT * FROM OrderDetails;
SELECT * FROM OrderHeader;
SELECT * FROM Cart;
SELECT * FROM ProductsMenu;
SELECT * FROM Users;

CREATE TABLE ProductsMenu (
    Id INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Cart (
    ProductId INT PRIMARY KEY,
    Qty INT NOT NULL,
    FOREIGN KEY (ProductId) REFERENCES ProductsMenu(Id)
);

CREATE TABLE Users (
    User_ID INT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL
);

CREATE TABLE OrderHeader (
    OrderID INT PRIMARY KEY,
    User_ID INT NOT NULL,
    OrderDate TIMESTAMP NOT NULL,
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID)
);

CREATE TABLE OrderDetails (
    OrderHeaderID INT NOT NULL,
    ProdID INT NOT NULL,
    Qty INT NOT NULL,
    FOREIGN KEY (OrderHeaderID) REFERENCES OrderHeader(OrderID),
    FOREIGN KEY (ProdID) REFERENCES ProductsMenu(Id)
);



INSERT INTO ProductsMenu (Id, Name, Price) VALUES
(1, 'Coke', 10.00),
(2, 'Chips', 5.00),
(3, 'Laptop', 15000.00),
(4, 'Mouse', 250.00),
(5, 'Keyboard', 600.00),
(6, 'Monitor', 3000.00);


INSERT INTO Cart (ProductId, Qty) VALUES
(1, 2),
(2, 1);


INSERT INTO Users (User_ID, Username) VALUES
(1, 'Arnold'),
(2, 'Sheryl');


INSERT INTO OrderHeader (OrderID, User_ID, OrderDate) VALUES
(1, 2, '2015-04-15 15:30:00');


INSERT INTO OrderDetails (OrderHeaderID, ProdID, Qty) VALUES
(1, 1, 2),
(1, 2, 1);



-- Adding quantity
DO $$
Begin
-- Add Coke
    IF EXISTS (SELECT 1 FROM Cart WHERE productid = 1) THEN
        UPDATE Cart SET qty = qty + 1 WHERE productid = 1;
    ELSE
        INSERT INTO Cart (productid, qty) VALUES (1, 1);
    END IF;

-- Add Chips
    IF EXISTS (SELECT 1 FROM Cart WHERE productid = 2) THEN
        UPDATE Cart SET qty = qty + 1 WHERE productid = 2;
    ELSE
        INSERT INTO Cart (productid, qty) VALUES (2, 1);
    END IF;
End $$;

-- Deleting quantity
DO $$
Begin
-- If quantity > 1, decrement it
    IF EXISTS (
        SELECT 1 
        FROM Cart 
        WHERE product_id = 1 AND quantity > 1
    ) THEN
        UPDATE Cart
        SET quantity = quantity - 1
        WHERE product_id = 1;
    
-- If quantity = 1, remove the item entirely
    ELSIF EXISTS (
        SELECT 1 
        FROM Cart 
        WHERE product_id = 1 AND quantity = 1
    ) THEN
        DELETE FROM Cart
        WHERE product_id = 1;
    END IF;
END $$;




-- Functions

CREATE OR REPLACE FUNCTION add_to_cart(p_product_id INT, p_qty INT DEFAULT 1)
RETURNS INTEGER AS $$
DECLARE
    v_new_qty INT;
BEGIN
    -- Insert or increment quantity
    INSERT INTO cart (productid, qty)
    VALUES (p_product_id, p_qty)
    ON CONFLICT (productid)
    DO UPDATE SET qty = cart.qty + EXCLUDED.qty
    RETURNING qty INTO v_new_qty;

    RETURN v_new_qty;  -- return current qty in cart for that product
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION remove_from_cart(p_product_id INT, p_qty INT DEFAULT 1)
RETURNS TEXT AS $$
DECLARE
    current_qty INT;
BEGIN
    SELECT qty INTO current_qty
    FROM Cart
    WHERE productid = p_product_id;

    -- If product exists in the cart
    IF current_qty IS NOT NULL THEN
        IF current_qty > p_qty THEN
            UPDATE Cart
            SET qty = qty - p_qty
            WHERE productid = p_product_id;
			RETURN 'Products Removed';
        ELSE
            DELETE FROM Cart
            WHERE productid = p_product_id;
			RETURN 'Products Completely Removed';
        END IF;
    END IF;
END;

$$ LANGUAGE plpgsql;
DROP FUNCTION remove_from_cart(integer,integer)



CREATE OR REPLACE FUNCTION checkout_cart(p_user_id INT)
RETURNS TEXT AS $$
DECLARE
    v_order_id INT;
BEGIN
    -- A: Insert into OrderHeader
    INSERT INTO OrderHeader (OrderID, User_ID, OrderDate)
    VALUES (
        (SELECT COALESCE(MAX(OrderID), 0) + 1 FROM OrderHeader),
        p_user_id,
        NOW()
    )
    RETURNING OrderID INTO v_order_id;

    -- B: Insert cart contents into OrderDetails
    INSERT INTO OrderDetails (OrderHeaderID, ProdID, Qty)
    SELECT v_order_id, ProductId, Qty
    FROM Cart;

    -- C: Empty the cart
    DELETE FROM Cart;

	RETURN 'Checkout Successful';
END;
$$ LANGUAGE plpgsql;
DROP FUNCTION checkout_cart(integer)

 

-- Add
SELECT add_to_cart(1); -- Coke
SELECT add_to_cart(1, 100);     
SELECT add_to_cart(2); -- Chips    
SELECT * FROM cart;  

-- Remove
SELECT remove_from_cart(1, 105);  -- Coke
SELECT * FROM cart;

-- First checkout for user 1
SELECT * FROM Cart;  -- Before checkout
SELECT checkout_cart(1);
SELECT * FROM OrderHeader;
SELECT * FROM OrderDetails;

-- Second checkout for user 2
SELECT checkout_cart(2);
SELECT * FROM OrderHeader;
SELECT * FROM OrderDetails;


-- Print single order
SELECT oh.OrderID, oh.OrderDate, u.Username, pm.Name, pm.Price, od.Qty
FROM OrderHeader oh
INNER JOIN Users u ON oh.User_ID = u.User_ID
INNER JOIN OrderDetails od ON oh.OrderID = od.OrderHeaderID
INNER JOIN ProductsMenu pm ON od.ProdID = pm.Id
WHERE oh.OrderID = 2;

-- Print all orders for today
SELECT oh.OrderID, oh.OrderDate, u.Username, pm.Name, pm.Price, od.Qty
FROM OrderHeader oh
INNER JOIN Users u ON oh.User_ID = u.User_ID
INNER JOIN OrderDetails od ON oh.OrderID = od.OrderHeaderID
INNER JOIN ProductsMenu pm ON od.ProdID = pm.Id
WHERE DATE(oh.OrderDate) = CURRENT_DATE
ORDER BY oh.OrderID;