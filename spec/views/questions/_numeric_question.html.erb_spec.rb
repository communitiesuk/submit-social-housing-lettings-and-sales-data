describe 'questions/_numeric_question.html.erb' do
    context 'when given a label and value constraints' do
        let(:label) { "Test Label" }
        let(:min) { "1" }
        let(:max) { "150" }
        let(:locals) { {label: label, minimum: min, maximum: max} }

        before(:each) do
            render :partial => 'numeric_question', locals: locals
        end

        it 'displays a numeric entry field with a label' do     
            expect(rendered).to have_selector('//input[@type="number"]')
            expect(rendered).to have_selector("//label[contains('#{label}')]")
        end

        it 'validates for a given minimum input' do
            expect(rendered).to have_selector("//input[@min=#{min}]")
        end

        it 'validates for a given maximum input' do
            expect(rendered).to have_selector("//input[@max=#{max}]")
        end
    end
end