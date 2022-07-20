
;with cte_org 
as (

	select 
		org.id organisation_id,
		org.organisation_type_id,
		org.legacy_code,
		substring(org.legacy_code, 1, 3) region,
		substring(org.legacy_code, 4, 2) branch,
		p.organisation_membership organisation_membership_id,
		p.[description],
		1 as org_level
	from   Intermediary_Party.dbo.organisation  org
			inner join Intermediary_Party.dbo.party p
				on  p.id = org.id
	where p.organisation_membership is null
	and   org.organisation_type_id in (3, 4, 5)

	union all

	select 
		org.id organisation_id,
		org.organisation_type_id,
		org.legacy_code,
		substring(org.legacy_code, 1, 3) region,
		substring(org.legacy_code, 4, 2) branch,
		p.organisation_membership,
		p.[description],
		cte_org.org_level + 1
	from   Intermediary_Party.dbo.organisation  org
			inner join Intermediary_Party.dbo.party p
				on  p.id = org.id
			inner join cte_org
				on  cte_org.organisation_id = p.organisation_membership
	where org.organisation_type_id in (3, 4, 5)
)
select *
from   cte_org
order by legacy_code