class Location < ApplicationRecord
  validate :validate_postcode
  validates :units, :type_of_unit, :mobility_type, presence: true
  belongs_to :scheme
  has_many :lettings_logs, class_name: "LettingsLog"
  has_many :location_deactivation_periods, class_name: "LocationDeactivationPeriod"

  has_paper_trail

  before_save :lookup_postcode!, if: :postcode_changed?

  auto_strip_attributes :name

  attr_accessor :add_another_location

  scope :search_by_postcode, ->(postcode) { where("REPLACE(postcode, ' ', '') ILIKE ?", "%#{postcode.delete(' ')}%") }
  scope :search_by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :search_by, ->(param) { search_by_name(param).or(search_by_postcode(param)) }
  scope :started, -> { where("startdate <= ?", Time.zone.today).or(where(startdate: nil)) }
  scope :active, -> { where(confirmed: true).and(started) }

  LOCAL_AUTHORITIES = {
    "E07000223": "Adur",
    "E07000026": "Allerdale",
    "E07000032": "Amber Valley",
    "E07000224": "Arun",
    "E07000170": "Ashfield",
    "E07000105": "Ashford",
    "E07000200": "Babergh",
    "E09000002": "Barking and Dagenham",
    "E09000003": "Barnet",
    "E08000016": "Barnsley",
    "E07000027": "Barrow-in-Furness",
    "E07000066": "Basildon",
    "E07000084": "Basingstoke and Deane",
    "E07000171": "Bassetlaw",
    "E06000022": "Bath and North East Somerset",
    "E06000055": "Bedford",
    "E09000004": "Bexley",
    "E08000025": "Birmingham",
    "E07000129": "Blaby",
    "E06000008": "Blackburn with Darwen",
    "E06000009": "Blackpool",
    "E07000033": "Bolsover",
    "E08000001": "Bolton",
    "E07000136": "Boston",
    "E06000058": "Bournemouth, Christchurch and Poole",
    "E06000036": "Bracknell Forest",
    "E08000032": "Bradford",
    "E07000067": "Braintree",
    "E07000143": "Breckland",
    "E09000005": "Brent",
    "E07000068": "Brentwood",
    "E06000043": "Brighton and Hove",
    "E06000023": "Bristol, City of",
    "E07000144": "Broadland",
    "E09000006": "Bromley",
    "E07000234": "Bromsgrove",
    "E07000095": "Broxbourne",
    "E07000172": "Broxtowe",
    "E06000060": "Buckinghamshire",
    "E07000117": "Burnley",
    "E08000002": "Bury",
    "E08000033": "Calderdale",
    "E07000008": "Cambridge",
    "E09000007": "Camden",
    "E07000192": "Cannock Chase",
    "E07000106": "Canterbury",
    "E07000028": "Carlisle",
    "E07000069": "Castle Point",
    "E06000056": "Central Bedfordshire",
    "E07000130": "Charnwood",
    "E07000070": "Chelmsford",
    "E07000078": "Cheltenham",
    "E07000177": "Cherwell",
    "E06000049": "Cheshire East",
    "E06000050": "Cheshire West and Chester",
    "E07000034": "Chesterfield",
    "E07000225": "Chichester",
    "E07000118": "Chorley",
    "E09000001": "City of London",
    "E07000071": "Colchester",
    "E07000029": "Copeland",
    "E07000150": "Corby",
    "E06000052": "Cornwall",
    "E07000079": "Cotswold",
    "E06000047": "County Durham",
    "E08000026": "Coventry",
    "E07000163": "Craven",
    "E07000226": "Crawley",
    "E09000008": "Croydon",
    "E07000096": "Dacorum",
    "E06000005": "Darlington",
    "E07000107": "Dartford",
    "E07000151": "Daventry",
    "E06000015": "Derby",
    "E07000035": "Derbyshire Dales",
    "E08000017": "Doncaster",
    "E06000059": "Dorset",
    "E07000108": "Dover",
    "E08000027": "Dudley",
    "E09000009": "Ealing",
    "E07000009": "East Cambridgeshire",
    "E07000040": "East Devon",
    "E07000085": "East Hampshire",
    "E07000242": "East Hertfordshire",
    "E07000137": "East Lindsey",
    "E07000152": "East Northamptonshire",
    "E06000011": "East Riding of Yorkshire",
    "E07000193": "East Staffordshire",
    "E07000244": "East Suffolk",
    "E07000061": "Eastbourne",
    "E07000086": "Eastleigh",
    "E07000030": "Eden",
    "E07000207": "Elmbridge",
    "E09000010": "Enfield",
    "E07000072": "Epping Forest",
    "E07000208": "Epsom and Ewell",
    "E07000036": "Erewash",
    "E07000041": "Exeter",
    "E07000087": "Fareham",
    "E07000010": "Fenland",
    "E07000112": "Folkestone and Hythe",
    "E07000080": "Forest of Dean",
    "E07000119": "Fylde",
    "E08000037": "Gateshead",
    "E07000173": "Gedling",
    "E07000081": "Gloucester",
    "E07000088": "Gosport",
    "E07000109": "Gravesham",
    "E07000145": "Great Yarmouth",
    "E09000011": "Greenwich",
    "E07000209": "Guildford",
    "W06000002": "Gwynedd",
    "E09000012": "Hackney",
    "E06000006": "Halton",
    "E07000164": "Hambleton",
    "E09000013": "Hammersmith and Fulham",
    "E07000131": "Harborough",
    "E09000014": "Haringey",
    "E07000073": "Harlow",
    "E07000165": "Harrogate",
    "E09000015": "Harrow",
    "E07000089": "Hart",
    "E06000001": "Hartlepool",
    "E07000062": "Hastings",
    "E07000090": "Havant",
    "E09000016": "Havering",
    "E06000019": "Herefordshire, County of",
    "E07000098": "Hertsmere",
    "E07000037": "High Peak",
    "S12000017": "Highland",
    "E09000017": "Hillingdon",
    "E07000132": "Hinckley and Bosworth",
    "E07000227": "Horsham",
    "E09000018": "Hounslow",
    "E07000011": "Huntingdonshire",
    "E07000120": "Hyndburn",
    "E07000202": "Ipswich",
    "E06000046": "Isle of Wight",
    "E06000053": "Isles of Scilly",
    "E09000019": "Islington",
    "E09000020": "Kensington and Chelsea",
    "E07000153": "Kettering",
    "E07000146": "King’s Lynn and West Norfolk",
    "E06000010": "Kingston upon Hull, City of",
    "E09000021": "Kingston upon Thames",
    "E08000034": "Kirklees",
    "E08000011": "Knowsley",
    "E09000022": "Lambeth",
    "E07000121": "Lancaster",
    "E08000035": "Leeds",
    "E06000016": "Leicester",
    "E07000063": "Lewes",
    "E09000023": "Lewisham",
    "E07000194": "Lichfield",
    "E07000138": "Lincoln",
    "E08000012": "Liverpool",
    "E06000032": "Luton",
    "E07000110": "Maidstone",
    "E07000074": "Maldon",
    "E07000235": "Malvern Hills",
    "E08000003": "Manchester",
    "E07000174": "Mansfield",
    "E06000035": "Medway",
    "E07000133": "Melton",
    "E07000187": "Mendip",
    "E09000024": "Merton",
    "E07000042": "Mid Devon",
    "E07000203": "Mid Suffolk",
    "E07000228": "Mid Sussex",
    "E06000002": "Middlesbrough",
    "E06000042": "Milton Keynes",
    "E07000210": "Mole Valley",
    "E07000091": "New Forest",
    "E07000175": "Newark and Sherwood",
    "E08000021": "Newcastle upon Tyne",
    "E07000195": "Newcastle-under-Lyme",
    "E09000025": "Newham",
    "E07000043": "North Devon",
    "E07000038": "North East Derbyshire",
    "E06000012": "North East Lincolnshire",
    "E07000099": "North Hertfordshire",
    "E07000139": "North Kesteven",
    "E06000013": "North Lincolnshire",
    "E07000147": "North Norfolk",
    "E06000024": "North Somerset",
    "E08000022": "North Tyneside",
    "E07000218": "North Warwickshire",
    "E07000134": "North West Leicestershire",
    "E07000154": "Northampton",
    "E06000057": "Northumberland",
    "E07000148": "Norwich",
    "E06000018": "Nottingham",
    "E07000219": "Nuneaton and Bedworth",
    "E07000135": "Oadby and Wigston",
    "E08000004": "Oldham",
    "E07000178": "Oxford",
    "E07000122": "Pendle",
    "E06000031": "Peterborough",
    "E06000026": "Plymouth",
    "E06000044": "Portsmouth",
    "E07000123": "Preston",
    "E06000038": "Reading",
    "E09000026": "Redbridge",
    "E06000003": "Redcar and Cleveland",
    "E07000236": "Redditch",
    "E07000211": "Reigate and Banstead",
    "E07000124": "Ribble Valley",
    "E09000027": "Richmond upon Thames",
    "E07000166": "Richmondshire",
    "E08000005": "Rochdale",
    "E07000075": "Rochford",
    "E07000125": "Rossendale",
    "E07000064": "Rother",
    "E08000018": "Rotherham",
    "E07000220": "Rugby",
    "E07000212": "Runnymede",
    "E07000176": "Rushcliffe",
    "E07000092": "Rushmoor",
    "E06000017": "Rutland",
    "E07000167": "Ryedale",
    "E08000006": "Salford",
    "E08000028": "Sandwell",
    "E07000168": "Scarborough",
    "E07000188": "Sedgemoor",
    "E08000014": "Sefton",
    "E07000169": "Selby",
    "E07000111": "Sevenoaks",
    "E08000019": "Sheffield",
    "E06000051": "Shropshire",
    "E06000039": "Slough",
    "E08000029": "Solihull",
    "E07000246": "Somerset West and Taunton",
    "E07000012": "South Cambridgeshire",
    "E07000039": "South Derbyshire",
    "E06000025": "South Gloucestershire",
    "E07000044": "South Hams",
    "E07000140": "South Holland",
    "E07000141": "South Kesteven",
    "E07000031": "South Lakeland",
    "E07000149": "South Norfolk",
    "E07000155": "South Northamptonshire",
    "E07000179": "South Oxfordshire",
    "E07000126": "South Ribble",
    "E07000189": "South Somerset",
    "E07000196": "South Staffordshire",
    "E08000023": "South Tyneside",
    "E06000045": "Southampton",
    "E06000033": "Southend-on-Sea",
    "E09000028": "Southwark",
    "E07000213": "Spelthorne",
    "E07000240": "St Albans",
    "E08000013": "St. Helens",
    "E07000197": "Stafford",
    "E07000198": "Staffordshire Moorlands",
    "E07000243": "Stevenage",
    "E08000007": "Stockport",
    "E06000004": "Stockton-on-Tees",
    "E06000021": "Stoke-on-Trent",
    "E07000221": "Stratford-on-Avon",
    "E07000082": "Stroud",
    "E08000024": "Sunderland",
    "E07000214": "Surrey Heath",
    "E09000029": "Sutton",
    "E07000113": "Swale",
    "E06000030": "Swindon",
    "E08000008": "Tameside",
    "E07000199": "Tamworth",
    "E07000215": "Tandridge",
    "E07000045": "Teignbridge",
    "E06000020": "Telford and Wrekin",
    "E07000076": "Tendring",
    "E07000093": "Test Valley",
    "E07000083": "Tewkesbury",
    "E07000114": "Thanet",
    "E07000102": "Three Rivers",
    "E06000034": "Thurrock",
    "E07000115": "Tonbridge and Malling",
    "E06000027": "Torbay",
    "E07000046": "Torridge",
    "E09000030": "Tower Hamlets",
    "E08000009": "Trafford",
    "E07000116": "Tunbridge Wells",
    "E07000077": "Uttlesford",
    "E07000180": "Vale of White Horse",
    "E08000036": "Wakefield",
    "E08000030": "Walsall",
    "E09000031": "Waltham Forest",
    "E09000032": "Wandsworth",
    "E06000007": "Warrington",
    "E07000222": "Warwick",
    "E07000103": "Watford",
    "E07000216": "Waverley",
    "E07000065": "Wealden",
    "E07000156": "Wellingborough",
    "E07000241": "Welwyn Hatfield",
    "E06000037": "West Berkshire",
    "E07000047": "West Devon",
    "E07000127": "West Lancashire",
    "E07000142": "West Lindsey",
    "E07000181": "West Oxfordshire",
    "E07000245": "West Suffolk",
    "E09000033": "Westminster",
    "E08000010": "Wigan",
    "E06000054": "Wiltshire",
    "E07000094": "Winchester",
    "E06000040": "Windsor and Maidenhead",
    "E08000015": "Wirral",
    "E07000217": "Woking",
    "E06000041": "Wokingham",
    "E08000031": "Wolverhampton",
    "E07000237": "Worcester",
    "E07000229": "Worthing",
    "E07000238": "Wychavon",
    "E07000128": "Wyre",
    "E07000239": "Wyre Forest",
    "E06000014": "York",
  }.freeze

  enum local_authorities: LOCAL_AUTHORITIES

  MOBILITY_TYPE = {
    "Wheelchair-user standard": "W",
    "Fitted with equipment and adaptations": "A",
    "Property designed to accessible general standard": "M",
    "None": "N",
    "Missing": "X",
  }.freeze

  enum mobility_type: MOBILITY_TYPE

  TYPE_OF_UNIT = {
    "Bungalow": 6,
    "Self-contained flat or bedsit": 1,
    "Self-contained flat or bedsit with common facilities": 2,
    "Self-contained house": 7,
    "Shared flat": 3,
    "Shared house or hostel": 4,
  }.freeze

  enum type_of_unit: TYPE_OF_UNIT

  def postcode=(postcode)
    if postcode
      super UKPostcode.parse(postcode).to_s
    else
      super nil
    end
  end

  def available_from
    startdate || [created_at, FormHandler.instance.current_collection_start_date].min
  end

  def status
    open_deactivation = location_deactivation_periods.deactivations_without_reactivation.first
    recent_deactivation = location_deactivation_periods.order("created_at").last

    return :deactivated if open_deactivation&.deactivation_date.present? && Time.zone.now >= open_deactivation.deactivation_date
    return :deactivating_soon if open_deactivation&.deactivation_date.present? && Time.zone.now < open_deactivation.deactivation_date
    return :reactivating_soon if recent_deactivation&.reactivation_date.present? && Time.zone.now < recent_deactivation.reactivation_date
    return :activating_soon if startdate.present? && Time.zone.now < startdate

    :active
  end

  def active?
    status == :active
  end

  def reactivating_soon?
    status == :reactivating_soon
  end

  def status_during(date)
    return :reactivating_soon if location_deactivation_periods.any? { |period| period.reactivation_date.present? && date.between?(period.deactivation_date, period.reactivation_date) } || available_from > date

    open_deactivation = location_deactivation_periods.deactivations_without_reactivation.first
    return :deactivated if open_deactivation.present? && open_deactivation.deactivation_date < date
  end

private

  PIO = PostcodeService.new

  def validate_postcode
    if postcode.nil? || !postcode&.match(POSTCODE_REGEXP)
      error_message = I18n.t("validations.postcode")
      errors.add :postcode, error_message
    end
  end

  def lookup_postcode!
    result = PIO.lookup(postcode)
    if result
      self.location_code = result[:location_code]
      self.location_admin_district = result[:location_admin_district]
    end
  end
end
