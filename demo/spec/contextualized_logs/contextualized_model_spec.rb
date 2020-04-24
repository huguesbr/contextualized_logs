require 'rails_helper'

module ContextualizedLogs
  RSpec.describe ContextualizedModel do
    before do
      CurrentContext.contextualized_model_enabled = contextualized_model_enabled
    end

    RSpec.shared_examples 'after_find context' do |context|
      describe '.after_find' do
        it 'does' do
          model = FactoryBot.create(:model, value: 'a')
          CurrentContext.reset
          CurrentContext.contextualized_model_enabled = contextualized_model_enabled
          Model.find(model.id)
          expect(CurrentContext.context_values).to eq(context)
        end
      end
    end

    RSpec.shared_examples 'after_create context' do |context|
      describe '.after_create' do
        it 'set context' do
          FactoryBot.create(:model, value: 'a')
          expect(CurrentContext.context_values).to eq(context)
        end
      end
    end

    context 'with CurrentContext.contextualized_model_enabled == true' do
      let(:contextualized_model_enabled) { true }

      it_behaves_like 'after_create context', {values: ['a']}
      it_behaves_like 'after_find context', {values: ['a']}
    end

    context 'with CurrentContext.contextualized_model_enabled == false' do
      let(:contextualized_model_enabled) { false }

      it_behaves_like 'after_create context', nil
      it_behaves_like 'after_find context', nil
    end
  end
end
