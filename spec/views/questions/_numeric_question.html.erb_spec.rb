describe 'questions/_numeric_question.html.erb' do
    context 'when given a label' do
        let(:label) { "Test Label" }

        it 'displays a numeric entry field' do
            render :partial => 'numeric_question', locals: { label: label }
            expect(rendered).to have_selector('//input[@type="number"]')
            expect(rendered).to have_selector("//label[contains('#{label}')]")
        end
    end
end