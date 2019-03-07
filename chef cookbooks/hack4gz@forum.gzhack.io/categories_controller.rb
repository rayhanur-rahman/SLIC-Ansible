require_dependency 'category_serializer'

class CategoriesController < ApplicationController

  before_filter :ensure_logged_in, except: [:index, :show]
  before_filter :fetch_category, only: [:show, :update, :destroy]
  skip_before_filter :check_xhr, only: [:index]

  def index
    @description = SiteSetting.site_description

    options = {}
    options[:latest_posts] = params[:latest_posts] || SiteSetting.category_featured_topics

    @list = CategoryList.new(guardian,options)
    @list.draft_key = Draft::NEW_TOPIC
    @list.draft_sequence = DraftSequence.current(current_user, Draft::NEW_TOPIC)
    @list.draft = Draft.get(current_user, @list.draft_key, @list.draft_sequence) if current_user

    discourse_expires_in 1.minute

    store_preloaded("categories_list", MultiJson.dump(CategoryListSerializer.new(@list, scope: guardian)))
    respond_to do |format|
      format.html { render }
      format.json { render_serialized(@list, CategoryListSerializer) }
    end
  end

  def move
    guardian.ensure_can_create!(Category)

    params.require("category_id")
    params.require("position")

    if category = Category.find(params["category_id"])
      category.move_to(params["position"].to_i)
      render json: success_json
    else
      render status: 500, json: failed_json
    end
  end

  def show
    if Category.topic_create_allowed(guardian).where(id: @category.id).exists?
      @category.permission = CategoryGroup.permission_types[:full]
    end
    render_serialized(@category, CategorySerializer)
  end

  def create
    guardian.ensure_can_create!(Category)

    @category = Category.create(category_params.merge(user: current_user))
    return render_json_error(@category) unless @category.save

    @category.move_to(category_params[:position].to_i) if category_params[:position]
    render_serialized(@category, CategorySerializer)
  end

  def update
    guardian.ensure_can_edit!(@category)
    json_result(@category, serializer: CategorySerializer) { |cat|
      if category_params[:position]
        category_params[:position] == 'default' ? cat.use_default_position : cat.move_to(category_params[:position].to_i)
      end
      if category_params.key? :email_in and category_params[:email_in].length == 0
        # properly null the value so the database constrain doesn't catch us
        category_params[:email_in] = nil
      end
      category_params.delete(:position)
      cat.update_attributes(category_params)
    }
  end

  def destroy
    guardian.ensure_can_delete!(@category)
    @category.destroy

    render json: success_json
  end

  private

    def required_param_keys
      [:name, :color, :text_color]
    end

    def category_params
      @category_params ||= begin
        required_param_keys.each do |key|
          params.require(key)
        end

        if p = params[:permissions]
          p.each do |k,v|
            p[k] = v.to_i
          end
        end

        params.permit(*required_param_keys, :position, :email_in, :email_in_allow_strangers, :parent_category_id, :auto_close_hours, :permissions => [*p.try(:keys)])
      end
    end

    def fetch_category
      @category = Category.where(slug: params[:id]).first || Category.where(id: params[:id].to_i).first
    end
end
