## Service Invoice - Summary by product

SELECT
  CASE `products`.`billing`
    WHEN 0 THEN 'Other'
    WHEN 1 THEN 'Non-Recurring'
    WHEN 2 THEN 'Recurring'
    WHEN 3 THEN 'Usage'
    WHEN 4 THEN 'Taxes'
  END AS `billing_type`,
  `products`.`name` AS `product_name`,
  SUM(`line_items`.`quantity`) AS `qty_total`,
  SUM(`line_items`.`total`) AS `amount_total`
FROM `boms`
INNER JOIN `line_items`
  ON `line_items`.`bom_id` = `boms`.`id`
INNER JOIN `products`
  ON `line_items`.`product_id` = `products`.`id`
WHERE
  `type` = 'ServiceInvoice'
  AND `invoice_date` BETWEEN '2017-02-01' AND '2017-03-01'
GROUP BY
  `product_id`
ORDER BY
  `products`.`billing`,
  `products`.`name`;
