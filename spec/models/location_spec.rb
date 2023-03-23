require "rails_helper"

RSpec.describe Location, type: :model do
  before do
    LocalAuthorityLink.create(local_authority_id: LocalAuthority.find_by(code: "E07000030").id, linked_local_authority_id: LocalAuthority.find_by(code: "E06000063").id)
  end

  describe "#new" do
    let(:location) { FactoryBot.build(:location) }

    before do
      stub_request(:get, /api.postcodes.io/)
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})

      stub_request(:get, /api.postcodes.io\/postcodes\/CA101AA/)
      .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Eden","codes":{"admin_district":"E07000030"}}}', headers: {})
    end

    it "belongs to an organisation" do
      expect(location.scheme).to be_a(Scheme)
    end

    it "infers the local authority" do
      location.postcode = "M1 1AE"
      location.save!
      expect(location.location_code).to eq("E08000003")
    end

    it "infers and returns the list of local authorities" do
      location.update!(postcode: "CA10 1AA")
      expect(location.linked_local_authorities.count).to eq(2)
      expect(location.linked_local_authorities.active(Time.zone.local(2022, 4, 1)).first.code).to eq("E07000030")
      expect(location.linked_local_authorities.active(Time.zone.local(2023, 4, 1)).first.code).to eq("E06000063")
    end

    context "when location_code is no in LocalAuthorities table" do
      before do
        stub_request(:get, /api.postcodes.io\/postcodes\/CA101AA/)
          .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Eden","codes":{"admin_district":"E01231231"}}}', headers: {})
      end

      it "defaults for location code for la" do
        location.update!(postcode: "CA10 1AA")
        expect(location.linked_local_authorities.count).to eq(0)
        expect(location.location_code).to eq("E01231231")
      end
    end
  end

  describe "#postcode" do
    let(:location) { FactoryBot.build(:location) }

    it "does not add an error if postcode is valid" do
      location.postcode = "M1 1AE"
      location.save!
      expect(location.errors).to be_empty
    end

    it "does add an error when the postcode is invalid" do
      location.postcode = "invalid"
      location.valid?(:postcode)
      expect(location.errors.count).to eq(1)
    end

    it "does add an error when the postcode is missing" do
      location.postcode = nil
      location.valid?(:postcode)
      expect(location.errors.count).to eq(1)
    end
  end

  describe "#local_authority" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the local authority is invalid" do
      location.location_admin_district = nil
      location.valid?(:location_admin_district)
      expect(location.errors.count).to eq(1)
    end
  end

  describe "#local_authorities_for_current_year" do
    context "when the current collection year is 22/23" do
      let(:today) { Time.zone.local(2022, 4, 1) }

      before do
        Timecop.freeze(today)
      end

      after do
        Timecop.unfreeze
      end

      it "returns a list of local authorities" do
        expect(described_class.local_authorities_for_current_year).to eq({
          "E07000223" => "Adur",
          "E07000026" => "Allerdale",
          "E07000032" => "Amber Valley",
          "E07000224" => "Arun",
          "E07000170" => "Ashfield",
          "E07000105" => "Ashford",
          "E07000200" => "Babergh",
          "E09000002" => "Barking and Dagenham",
          "E09000003" => "Barnet",
          "E08000016" => "Barnsley",
          "E07000027" => "Barrow-in-Furness",
          "E07000066" => "Basildon",
          "E07000084" => "Basingstoke and Deane",
          "E07000171" => "Bassetlaw",
          "E06000022" => "Bath and North East Somerset",
          "E06000055" => "Bedford",
          "E09000004" => "Bexley",
          "E08000025" => "Birmingham",
          "E07000129" => "Blaby",
          "E06000008" => "Blackburn with Darwen",
          "E06000009" => "Blackpool",
          "E07000033" => "Bolsover",
          "E08000001" => "Bolton",
          "E07000136" => "Boston",
          "E06000058" => "Bournemouth, Christchurch and Poole",
          "E06000036" => "Bracknell Forest",
          "E08000032" => "Bradford",
          "E07000067" => "Braintree",
          "E07000143" => "Breckland",
          "E09000005" => "Brent",
          "E07000068" => "Brentwood",
          "E06000043" => "Brighton and Hove",
          "E06000023" => "Bristol, City of",
          "E07000144" => "Broadland",
          "E09000006" => "Bromley",
          "E07000234" => "Bromsgrove",
          "E07000095" => "Broxbourne",
          "E07000172" => "Broxtowe",
          "E06000060" => "Buckinghamshire",
          "E07000117" => "Burnley",
          "E08000002" => "Bury",
          "E08000033" => "Calderdale",
          "E07000008" => "Cambridge",
          "E09000007" => "Camden",
          "E07000192" => "Cannock Chase",
          "E07000106" => "Canterbury",
          "E07000028" => "Carlisle",
          "E07000069" => "Castle Point",
          "E06000056" => "Central Bedfordshire",
          "E07000130" => "Charnwood",
          "E07000070" => "Chelmsford",
          "E07000078" => "Cheltenham",
          "E07000177" => "Cherwell",
          "E06000049" => "Cheshire East",
          "E06000050" => "Cheshire West and Chester",
          "E07000034" => "Chesterfield",
          "E07000225" => "Chichester",
          "E07000118" => "Chorley",
          "E09000001" => "City of London",
          "E07000071" => "Colchester",
          "E07000029" => "Copeland",
          "E07000150" => "Corby",
          "E06000052" => "Cornwall",
          "E07000079" => "Cotswold",
          "E06000047" => "County Durham",
          "E08000026" => "Coventry",
          "E07000163" => "Craven",
          "E07000226" => "Crawley",
          "E09000008" => "Croydon",
          "E07000096" => "Dacorum",
          "E06000005" => "Darlington",
          "E07000107" => "Dartford",
          "E07000151" => "Daventry",
          "E06000015" => "Derby",
          "E07000035" => "Derbyshire Dales",
          "E08000017" => "Doncaster",
          "E06000059" => "Dorset",
          "E07000108" => "Dover",
          "E08000027" => "Dudley",
          "E09000009" => "Ealing",
          "E07000009" => "East Cambridgeshire",
          "E07000040" => "East Devon",
          "E07000085" => "East Hampshire",
          "E07000242" => "East Hertfordshire",
          "E07000137" => "East Lindsey",
          "E07000152" => "East Northamptonshire",
          "E06000011" => "East Riding of Yorkshire",
          "E07000193" => "East Staffordshire",
          "E07000244" => "East Suffolk",
          "E07000061" => "Eastbourne",
          "E07000086" => "Eastleigh",
          "E07000030" => "Eden",
          "E07000207" => "Elmbridge",
          "E09000010" => "Enfield",
          "E07000072" => "Epping Forest",
          "E07000208" => "Epsom and Ewell",
          "E07000036" => "Erewash",
          "E07000041" => "Exeter",
          "E07000087" => "Fareham",
          "E07000010" => "Fenland",
          "E07000112" => "Folkestone and Hythe",
          "E07000080" => "Forest of Dean",
          "E07000119" => "Fylde",
          "E08000037" => "Gateshead",
          "E07000173" => "Gedling",
          "E07000081" => "Gloucester",
          "E07000088" => "Gosport",
          "E07000109" => "Gravesham",
          "E07000145" => "Great Yarmouth",
          "E09000011" => "Greenwich",
          "E07000209" => "Guildford",
          "E09000012" => "Hackney",
          "E06000006" => "Halton",
          "E07000164" => "Hambleton",
          "E09000013" => "Hammersmith and Fulham",
          "E07000131" => "Harborough",
          "E09000014" => "Haringey",
          "E07000073" => "Harlow",
          "E07000165" => "Harrogate",
          "E09000015" => "Harrow",
          "E07000089" => "Hart",
          "E06000001" => "Hartlepool",
          "E07000062" => "Hastings",
          "E07000090" => "Havant",
          "E09000016" => "Havering",
          "E06000019" => "Herefordshire, County of",
          "E07000098" => "Hertsmere",
          "E07000037" => "High Peak",
          "E09000017" => "Hillingdon",
          "E07000132" => "Hinckley and Bosworth",
          "E07000227" => "Horsham",
          "E09000018" => "Hounslow",
          "E07000011" => "Huntingdonshire",
          "E07000120" => "Hyndburn",
          "E07000202" => "Ipswich",
          "E06000046" => "Isle of Wight",
          "E06000053" => "Isles of Scilly",
          "E09000019" => "Islington",
          "E09000020" => "Kensington and Chelsea",
          "E07000153" => "Kettering",
          "E07000146" => "King’s Lynn and West Norfolk",
          "E06000010" => "Kingston upon Hull, City of",
          "E09000021" => "Kingston upon Thames",
          "E08000034" => "Kirklees",
          "E08000011" => "Knowsley",
          "E09000022" => "Lambeth",
          "E07000121" => "Lancaster",
          "E08000035" => "Leeds",
          "E06000016" => "Leicester",
          "E07000063" => "Lewes",
          "E09000023" => "Lewisham",
          "E07000194" => "Lichfield",
          "E07000138" => "Lincoln",
          "E08000012" => "Liverpool",
          "E06000032" => "Luton",
          "E07000110" => "Maidstone",
          "E07000074" => "Maldon",
          "E07000235" => "Malvern Hills",
          "E08000003" => "Manchester",
          "E07000174" => "Mansfield",
          "E06000035" => "Medway",
          "E07000133" => "Melton",
          "E07000187" => "Mendip",
          "E09000024" => "Merton",
          "E07000042" => "Mid Devon",
          "E07000203" => "Mid Suffolk",
          "E07000228" => "Mid Sussex",
          "E06000002" => "Middlesbrough",
          "E06000042" => "Milton Keynes",
          "E07000210" => "Mole Valley",
          "E07000091" => "New Forest",
          "E07000175" => "Newark and Sherwood",
          "E08000021" => "Newcastle upon Tyne",
          "E07000195" => "Newcastle-under-Lyme",
          "E09000025" => "Newham",
          "E07000043" => "North Devon",
          "E07000038" => "North East Derbyshire",
          "E06000012" => "North East Lincolnshire",
          "E07000099" => "North Hertfordshire",
          "E07000139" => "North Kesteven",
          "E06000013" => "North Lincolnshire",
          "E07000147" => "North Norfolk",
          "E06000024" => "North Somerset",
          "E08000022" => "North Tyneside",
          "E07000218" => "North Warwickshire",
          "E07000134" => "North West Leicestershire",
          "E07000154" => "Northampton",
          "E06000057" => "Northumberland",
          "E07000148" => "Norwich",
          "E06000018" => "Nottingham",
          "E07000219" => "Nuneaton and Bedworth",
          "E07000135" => "Oadby and Wigston",
          "E08000004" => "Oldham",
          "E07000178" => "Oxford",
          "E07000122" => "Pendle",
          "E06000031" => "Peterborough",
          "E06000026" => "Plymouth",
          "E06000044" => "Portsmouth",
          "E07000123" => "Preston",
          "E06000038" => "Reading",
          "E09000026" => "Redbridge",
          "E06000003" => "Redcar and Cleveland",
          "E07000236" => "Redditch",
          "E07000211" => "Reigate and Banstead",
          "E07000124" => "Ribble Valley",
          "E09000027" => "Richmond upon Thames",
          "E07000166" => "Richmondshire",
          "E08000005" => "Rochdale",
          "E07000075" => "Rochford",
          "E07000125" => "Rossendale",
          "E07000064" => "Rother",
          "E08000018" => "Rotherham",
          "E07000220" => "Rugby",
          "E07000212" => "Runnymede",
          "E07000176" => "Rushcliffe",
          "E07000092" => "Rushmoor",
          "E06000017" => "Rutland",
          "E07000167" => "Ryedale",
          "E08000006" => "Salford",
          "E08000028" => "Sandwell",
          "E07000168" => "Scarborough",
          "E07000188" => "Sedgemoor",
          "E08000014" => "Sefton",
          "E07000169" => "Selby",
          "E07000111" => "Sevenoaks",
          "E08000019" => "Sheffield",
          "E06000051" => "Shropshire",
          "E06000039" => "Slough",
          "E08000029" => "Solihull",
          "E07000246" => "Somerset West and Taunton",
          "E07000012" => "South Cambridgeshire",
          "E07000039" => "South Derbyshire",
          "E06000025" => "South Gloucestershire",
          "E07000044" => "South Hams",
          "E07000140" => "South Holland",
          "E07000141" => "South Kesteven",
          "E07000031" => "South Lakeland",
          "E07000149" => "South Norfolk",
          "E07000155" => "South Northamptonshire",
          "E07000179" => "South Oxfordshire",
          "E07000126" => "South Ribble",
          "E07000189" => "South Somerset",
          "E07000196" => "South Staffordshire",
          "E08000023" => "South Tyneside",
          "E06000045" => "Southampton",
          "E06000033" => "Southend-on-Sea",
          "E09000028" => "Southwark",
          "E07000213" => "Spelthorne",
          "E07000240" => "St Albans",
          "E08000013" => "St. Helens",
          "E07000197" => "Stafford",
          "E07000198" => "Staffordshire Moorlands",
          "E07000243" => "Stevenage",
          "E08000007" => "Stockport",
          "E06000004" => "Stockton-on-Tees",
          "E06000021" => "Stoke-on-Trent",
          "E07000221" => "Stratford-on-Avon",
          "E07000082" => "Stroud",
          "E08000024" => "Sunderland",
          "E07000214" => "Surrey Heath",
          "E09000029" => "Sutton",
          "E07000113" => "Swale",
          "E06000030" => "Swindon",
          "E08000008" => "Tameside",
          "E07000199" => "Tamworth",
          "E07000215" => "Tandridge",
          "E07000045" => "Teignbridge",
          "E06000020" => "Telford and Wrekin",
          "E07000076" => "Tendring",
          "E07000093" => "Test Valley",
          "E07000083" => "Tewkesbury",
          "E07000114" => "Thanet",
          "E07000102" => "Three Rivers",
          "E06000034" => "Thurrock",
          "E07000115" => "Tonbridge and Malling",
          "E06000027" => "Torbay",
          "E07000046" => "Torridge",
          "E09000030" => "Tower Hamlets",
          "E08000009" => "Trafford",
          "E07000116" => "Tunbridge Wells",
          "E07000077" => "Uttlesford",
          "E07000180" => "Vale of White Horse",
          "E08000036" => "Wakefield",
          "E08000030" => "Walsall",
          "E09000031" => "Waltham Forest",
          "E09000032" => "Wandsworth",
          "E06000007" => "Warrington",
          "E07000222" => "Warwick",
          "E07000103" => "Watford",
          "E07000216" => "Waverley",
          "E07000065" => "Wealden",
          "E07000156" => "Wellingborough",
          "E07000241" => "Welwyn Hatfield",
          "E06000037" => "West Berkshire",
          "E07000047" => "West Devon",
          "E07000127" => "West Lancashire",
          "E07000142" => "West Lindsey",
          "E07000181" => "West Oxfordshire",
          "E07000245" => "West Suffolk",
          "E09000033" => "Westminster",
          "E08000010" => "Wigan",
          "E06000054" => "Wiltshire",
          "E07000094" => "Winchester",
          "E06000040" => "Windsor and Maidenhead",
          "E08000015" => "Wirral",
          "E07000217" => "Woking",
          "E06000041" => "Wokingham",
          "E08000031" => "Wolverhampton",
          "E07000237" => "Worcester",
          "E07000229" => "Worthing",
          "E07000238" => "Wychavon",
          "E07000128" => "Wyre",
          "E07000239" => "Wyre Forest",
          "E06000014" => "York",
        })
      end
    end

    context "when the current collection year is 23/24" do
      let(:today) { Time.zone.local(2023, 5, 1) }

      before do
        Timecop.freeze(today)
      end

      after do
        Timecop.unfreeze
      end

      it "returns a list of local authorities" do
        expect(described_class.local_authorities_for_current_year).to eq({
          "E07000223" => "Adur",
          "E07000032" => "Amber Valley",
          "E07000224" => "Arun",
          "E07000170" => "Ashfield",
          "E07000105" => "Ashford",
          "E07000200" => "Babergh",
          "E09000002" => "Barking and Dagenham",
          "E09000003" => "Barnet",
          "E08000016" => "Barnsley",
          "E07000066" => "Basildon",
          "E07000084" => "Basingstoke and Deane",
          "E07000171" => "Bassetlaw",
          "E06000022" => "Bath and North East Somerset",
          "E06000055" => "Bedford",
          "E09000004" => "Bexley",
          "E08000025" => "Birmingham",
          "E07000129" => "Blaby",
          "E06000008" => "Blackburn with Darwen",
          "E06000009" => "Blackpool",
          "E07000033" => "Bolsover",
          "E08000001" => "Bolton",
          "E07000136" => "Boston",
          "E06000058" => "Bournemouth, Christchurch and Poole",
          "E06000036" => "Bracknell Forest",
          "E08000032" => "Bradford",
          "E07000067" => "Braintree",
          "E07000143" => "Breckland",
          "E09000005" => "Brent",
          "E07000068" => "Brentwood",
          "E06000043" => "Brighton and Hove",
          "E06000023" => "Bristol, City of",
          "E07000144" => "Broadland",
          "E09000006" => "Bromley",
          "E07000234" => "Bromsgrove",
          "E07000095" => "Broxbourne",
          "E07000172" => "Broxtowe",
          "E06000060" => "Buckinghamshire",
          "E07000117" => "Burnley",
          "E08000002" => "Bury",
          "E08000033" => "Calderdale",
          "E07000008" => "Cambridge",
          "E09000007" => "Camden",
          "E07000192" => "Cannock Chase",
          "E07000106" => "Canterbury",
          "E07000069" => "Castle Point",
          "E06000056" => "Central Bedfordshire",
          "E07000130" => "Charnwood",
          "E07000070" => "Chelmsford",
          "E07000078" => "Cheltenham",
          "E07000177" => "Cherwell",
          "E06000049" => "Cheshire East",
          "E06000050" => "Cheshire West and Chester",
          "E07000034" => "Chesterfield",
          "E07000225" => "Chichester",
          "E07000118" => "Chorley",
          "E09000001" => "City of London",
          "E07000071" => "Colchester",
          "E07000150" => "Corby",
          "E06000052" => "Cornwall",
          "E07000079" => "Cotswold",
          "E06000047" => "County Durham",
          "E08000026" => "Coventry",
          "E07000226" => "Crawley",
          "E09000008" => "Croydon",
          "E06000063" => "Cumberland",
          "E07000096" => "Dacorum",
          "E06000005" => "Darlington",
          "E07000107" => "Dartford",
          "E07000151" => "Daventry",
          "E06000015" => "Derby",
          "E07000035" => "Derbyshire Dales",
          "E08000017" => "Doncaster",
          "E06000059" => "Dorset",
          "E07000108" => "Dover",
          "E08000027" => "Dudley",
          "E09000009" => "Ealing",
          "E07000009" => "East Cambridgeshire",
          "E07000040" => "East Devon",
          "E07000085" => "East Hampshire",
          "E07000242" => "East Hertfordshire",
          "E07000137" => "East Lindsey",
          "E07000152" => "East Northamptonshire",
          "E06000011" => "East Riding of Yorkshire",
          "E07000193" => "East Staffordshire",
          "E07000244" => "East Suffolk",
          "E07000061" => "Eastbourne",
          "E07000086" => "Eastleigh",
          "E07000207" => "Elmbridge",
          "E09000010" => "Enfield",
          "E07000072" => "Epping Forest",
          "E07000208" => "Epsom and Ewell",
          "E07000036" => "Erewash",
          "E07000041" => "Exeter",
          "E07000087" => "Fareham",
          "E07000010" => "Fenland",
          "E07000112" => "Folkestone and Hythe",
          "E07000080" => "Forest of Dean",
          "E07000119" => "Fylde",
          "E08000037" => "Gateshead",
          "E07000173" => "Gedling",
          "E07000081" => "Gloucester",
          "E07000088" => "Gosport",
          "E07000109" => "Gravesham",
          "E07000145" => "Great Yarmouth",
          "E09000011" => "Greenwich",
          "E07000209" => "Guildford",
          "E09000012" => "Hackney",
          "E06000006" => "Halton",
          "E09000013" => "Hammersmith and Fulham",
          "E07000131" => "Harborough",
          "E09000014" => "Haringey",
          "E07000073" => "Harlow",
          "E09000015" => "Harrow",
          "E07000089" => "Hart",
          "E06000001" => "Hartlepool",
          "E07000062" => "Hastings",
          "E07000090" => "Havant",
          "E09000016" => "Havering",
          "E06000019" => "Herefordshire, County of",
          "E07000098" => "Hertsmere",
          "E07000037" => "High Peak",
          "E09000017" => "Hillingdon",
          "E07000132" => "Hinckley and Bosworth",
          "E07000227" => "Horsham",
          "E09000018" => "Hounslow",
          "E07000011" => "Huntingdonshire",
          "E07000120" => "Hyndburn",
          "E07000202" => "Ipswich",
          "E06000046" => "Isle of Wight",
          "E06000053" => "Isles of Scilly",
          "E09000019" => "Islington",
          "E09000020" => "Kensington and Chelsea",
          "E07000153" => "Kettering",
          "E07000146" => "King’s Lynn and West Norfolk",
          "E06000010" => "Kingston upon Hull, City of",
          "E09000021" => "Kingston upon Thames",
          "E08000034" => "Kirklees",
          "E08000011" => "Knowsley",
          "E09000022" => "Lambeth",
          "E07000121" => "Lancaster",
          "E08000035" => "Leeds",
          "E06000016" => "Leicester",
          "E07000063" => "Lewes",
          "E09000023" => "Lewisham",
          "E07000194" => "Lichfield",
          "E07000138" => "Lincoln",
          "E08000012" => "Liverpool",
          "E06000032" => "Luton",
          "E07000110" => "Maidstone",
          "E07000074" => "Maldon",
          "E07000235" => "Malvern Hills",
          "E08000003" => "Manchester",
          "E07000174" => "Mansfield",
          "E06000035" => "Medway",
          "E07000133" => "Melton",
          "E09000024" => "Merton",
          "E07000042" => "Mid Devon",
          "E07000203" => "Mid Suffolk",
          "E07000228" => "Mid Sussex",
          "E06000002" => "Middlesbrough",
          "E06000042" => "Milton Keynes",
          "E07000210" => "Mole Valley",
          "E07000091" => "New Forest",
          "E07000175" => "Newark and Sherwood",
          "E08000021" => "Newcastle upon Tyne",
          "E07000195" => "Newcastle-under-Lyme",
          "E09000025" => "Newham",
          "E07000043" => "North Devon",
          "E07000038" => "North East Derbyshire",
          "E06000012" => "North East Lincolnshire",
          "E07000099" => "North Hertfordshire",
          "E07000139" => "North Kesteven",
          "E06000013" => "North Lincolnshire",
          "E07000147" => "North Norfolk",
          "E06000024" => "North Somerset",
          "E08000022" => "North Tyneside",
          "E07000218" => "North Warwickshire",
          "E07000134" => "North West Leicestershire",
          "E06000065" => "North Yorkshire",
          "E07000154" => "Northampton",
          "E06000057" => "Northumberland",
          "E07000148" => "Norwich",
          "E06000018" => "Nottingham",
          "E07000219" => "Nuneaton and Bedworth",
          "E07000135" => "Oadby and Wigston",
          "E08000004" => "Oldham",
          "E07000178" => "Oxford",
          "E07000122" => "Pendle",
          "E06000031" => "Peterborough",
          "E06000026" => "Plymouth",
          "E06000044" => "Portsmouth",
          "E07000123" => "Preston",
          "E06000038" => "Reading",
          "E09000026" => "Redbridge",
          "E06000003" => "Redcar and Cleveland",
          "E07000236" => "Redditch",
          "E07000211" => "Reigate and Banstead",
          "E07000124" => "Ribble Valley",
          "E09000027" => "Richmond upon Thames",
          "E08000005" => "Rochdale",
          "E07000075" => "Rochford",
          "E07000125" => "Rossendale",
          "E07000064" => "Rother",
          "E08000018" => "Rotherham",
          "E07000220" => "Rugby",
          "E07000212" => "Runnymede",
          "E07000176" => "Rushcliffe",
          "E07000092" => "Rushmoor",
          "E06000017" => "Rutland",
          "E08000006" => "Salford",
          "E08000028" => "Sandwell",
          "E08000014" => "Sefton",
          "E07000111" => "Sevenoaks",
          "E08000019" => "Sheffield",
          "E06000051" => "Shropshire",
          "E06000039" => "Slough",
          "E08000029" => "Solihull",
          "E06000066" => "Somerset",
          "E07000012" => "South Cambridgeshire",
          "E07000039" => "South Derbyshire",
          "E06000025" => "South Gloucestershire",
          "E07000044" => "South Hams",
          "E07000140" => "South Holland",
          "E07000141" => "South Kesteven",
          "E07000149" => "South Norfolk",
          "E07000155" => "South Northamptonshire",
          "E07000179" => "South Oxfordshire",
          "E07000126" => "South Ribble",
          "E07000196" => "South Staffordshire",
          "E08000023" => "South Tyneside",
          "E06000045" => "Southampton",
          "E06000033" => "Southend-on-Sea",
          "E09000028" => "Southwark",
          "E07000213" => "Spelthorne",
          "E07000240" => "St Albans",
          "E08000013" => "St. Helens",
          "E07000197" => "Stafford",
          "E07000198" => "Staffordshire Moorlands",
          "E07000243" => "Stevenage",
          "E08000007" => "Stockport",
          "E06000004" => "Stockton-on-Tees",
          "E06000021" => "Stoke-on-Trent",
          "E07000221" => "Stratford-on-Avon",
          "E07000082" => "Stroud",
          "E08000024" => "Sunderland",
          "E07000214" => "Surrey Heath",
          "E09000029" => "Sutton",
          "E07000113" => "Swale",
          "E06000030" => "Swindon",
          "E08000008" => "Tameside",
          "E07000199" => "Tamworth",
          "E07000215" => "Tandridge",
          "E07000045" => "Teignbridge",
          "E06000020" => "Telford and Wrekin",
          "E07000076" => "Tendring",
          "E07000093" => "Test Valley",
          "E07000083" => "Tewkesbury",
          "E07000114" => "Thanet",
          "E07000102" => "Three Rivers",
          "E06000034" => "Thurrock",
          "E07000115" => "Tonbridge and Malling",
          "E06000027" => "Torbay",
          "E07000046" => "Torridge",
          "E09000030" => "Tower Hamlets",
          "E08000009" => "Trafford",
          "E07000116" => "Tunbridge Wells",
          "E07000077" => "Uttlesford",
          "E07000180" => "Vale of White Horse",
          "E08000036" => "Wakefield",
          "E08000030" => "Walsall",
          "E09000031" => "Waltham Forest",
          "E09000032" => "Wandsworth",
          "E06000007" => "Warrington",
          "E07000222" => "Warwick",
          "E07000103" => "Watford",
          "E07000216" => "Waverley",
          "E07000065" => "Wealden",
          "E07000156" => "Wellingborough",
          "E07000241" => "Welwyn Hatfield",
          "E06000037" => "West Berkshire",
          "E07000047" => "West Devon",
          "E07000127" => "West Lancashire",
          "E07000142" => "West Lindsey",
          "E07000181" => "West Oxfordshire",
          "E07000245" => "West Suffolk",
          "E09000033" => "Westminster",
          "E06000064" => "Westmorland and Furness",
          "E08000010" => "Wigan",
          "E06000054" => "Wiltshire",
          "E07000094" => "Winchester",
          "E06000040" => "Windsor and Maidenhead",
          "E08000015" => "Wirral",
          "E07000217" => "Woking",
          "E06000041" => "Wokingham",
          "E08000031" => "Wolverhampton",
          "E07000237" => "Worcester",
          "E07000229" => "Worthing",
          "E07000238" => "Wychavon",
          "E07000128" => "Wyre",
          "E07000239" => "Wyre Forest",
          "E06000014" => "York",
        })
      end
    end
  end

  describe "#name" do
    let(:location) { FactoryBot.build(:location) }

    it "does not add an error when the name is invalid" do
      location.name = nil
      location.valid?
      expect(location.errors.count).to eq(0)
    end
  end

  describe "#units" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the number of units is invalid" do
      location.units = nil
      location.valid?(:units)
      expect(location.errors.count).to eq(1)
    end
  end

  describe "#type_of_unit" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the type of unit is invalid" do
      location.type_of_unit = nil
      location.valid?(:type_of_unit)
      expect(location.errors.count).to eq(1)
    end
  end

  describe "#mobility_type" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the mobility type is invalid" do
      location.mobility_type = nil
      location.valid?(:mobility_type)
      expect(location.errors.count).to eq(1)
    end
  end

  describe "#availability" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the availability is invalid" do
      location.startdate = Time.zone.local(1, 1, 1)
      location.valid?(:startdate)
      expect(location.errors.count).to eq(1)
    end
  end

  describe "paper trail" do
    let(:location) { FactoryBot.create(:location) }
    let!(:name) { location.name }

    it "creates a record of changes to a log" do
      expect { location.update!(name: "new test name") }.to change(location.versions, :count).by(1)
    end

    it "allows lettings logs to be restored to a previous version" do
      location.update!(name: "new test name")
      expect(location.paper_trail.previous_version.name).to eq(name)
    end
  end

  describe "scopes" do
    before do
      FactoryBot.create(:location, name: "ABC", postcode: "NW1 8RR", startdate: Time.zone.today)
      FactoryBot.create(:location, name: "XYZ", postcode: "SE1 6HJ", startdate: Time.zone.today + 1.day)
      FactoryBot.create(:location, name: "GHQ", postcode: "EW1 7JK", startdate: Time.zone.today - 1.day, units: nil, confirmed: false)
      FactoryBot.create(:location, name: "GHQ", postcode: "EW1 7JK", startdate: nil)
    end

    context "when searching by name" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by_name("abc").count).to eq(1)
        expect(described_class.search_by_name("AbC").count).to eq(1)
      end
    end

    context "when searching by postcode" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by_postcode("se1 6hj").count).to eq(1)
        expect(described_class.search_by_postcode("SE1 6HJ").count).to eq(1)
      end
    end

    context "when searching by all searchable field" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by("aBc").count).to eq(1)
        expect(described_class.search_by("nw18rr").count).to eq(1)
      end
    end

    context "when filtering by started locations" do
      it "returns only locations that started today or earlier" do
        expect(described_class.started.count).to eq(3)
      end
    end

    context "when filtering by active locations" do
      it "returns only locations that started today or earlier and are complete (and so confirmed)" do
        expect(described_class.active.count).to eq(2)
      end
    end
  end

  describe "status" do
    let(:location) { FactoryBot.build(:location, startdate: Time.zone.local(2022, 4, 1)) }

    before do
      Timecop.freeze(2022, 6, 7)
    end

    after do
      Timecop.unfreeze
    end

    context "when location is not confirmed" do
      it "returns incomplete " do
        location.confirmed = false
        expect(location.status).to eq(:incomplete)
      end
    end

    context "when there have not been any previous deactivations" do
      it "returns active if the location has no deactivation records" do
        expect(location.status).to eq(:active)
      end

      it "returns deactivating soon if deactivation_date is in the future" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 8), location:)
        location.save!
        expect(location.status).to eq(:deactivating_soon)
      end

      it "returns deactivated if deactivation_date is in the past" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 6), location:)
        location.save!
        expect(location.status).to eq(:deactivated)
      end

      it "returns deactivated if deactivation_date is today" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), location:)
        location.save!
        expect(location.status).to eq(:deactivated)
      end

      it "returns reactivating soon if the location has a future reactivation date" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), reactivation_date: Time.zone.local(2022, 6, 8), location:)
        location.save!
        expect(location.status).to eq(:reactivating_soon)
      end

      it "returns activating soon if the location has a future startdate" do
        location.startdate = Time.zone.local(2022, 7, 7)
        location.save!
        expect(location.status).to eq(:activating_soon)
      end
    end

    context "when there have been previous deactivations" do
      before do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 4), reactivation_date: Time.zone.local(2022, 6, 5), location:)
        location.save!
      end

      it "returns active if the location has no relevant deactivation records" do
        expect(location.status).to eq(:active)
      end

      it "returns deactivating soon if deactivation_date is in the future" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 8), location:)
        location.save!
        expect(location.status).to eq(:deactivating_soon)
      end

      it "returns deactivated if deactivation_date is in the past" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 6), location:)
        location.save!
        expect(location.status).to eq(:deactivated)
      end

      it "returns deactivated if deactivation_date is today" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), location:)
        location.save!
        expect(location.status).to eq(:deactivated)
      end

      it "returns reactivating soon if the location has a future reactivation date" do
        Timecop.freeze(2022, 6, 8)
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), reactivation_date: Time.zone.local(2022, 6, 9), location:)
        location.save!
        expect(location.status).to eq(:reactivating_soon)
      end

      it "returns reactivating soon if the location had a deactivation during another deactivation" do
        Timecop.freeze(2022, 6, 4)
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 2), location:)
        location.save!
        expect(location.status).to eq(:reactivating_soon)
      end

      it "returns activating soon if the location has a future startdate" do
        location.startdate = Time.zone.local(2022, 7, 7)
        location.save!
        expect(location.status).to eq(:activating_soon)
      end
    end
  end

  describe "available_from" do
    context "when there is a startdate" do
      let(:location) { FactoryBot.build(:location, startdate: Time.zone.local(2022, 4, 6)) }

      it "returns the startdate" do
        expect(location.available_from).to eq(Time.zone.local(2022, 4, 6))
      end
    end

    context "when there is no start date" do
      context "and the location was created at the start of the 2022/23 collection window" do
        let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2022, 4, 6), startdate: nil) }

        it "returns the beginning of 22/23 collection window" do
          expect(location.available_from).to eq(Time.zone.local(2022, 4, 1))
        end
      end

      context "and the location was created at the end of the 2022/23 collection window" do
        let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2023, 2, 6), startdate: nil) }

        it "returns the beginning of 22/23 collection window" do
          expect(location.available_from).to eq(Time.zone.local(2022, 4, 1))
        end
      end

      context "and the location was created at the start of the 2021/22 collection window" do
        let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2021, 4, 6), startdate: nil) }

        it "returns the beginning of 21/22 collection window" do
          expect(location.available_from).to eq(Time.zone.local(2021, 4, 1))
        end
      end

      context "and the location was created at the end of the 2021/22 collection window" do
        let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2022, 2, 6), startdate: nil) }

        it "returns the beginning of 21/22 collection window" do
          expect(location.available_from).to eq(Time.zone.local(2021, 4, 1))
        end
      end
    end
  end
end
