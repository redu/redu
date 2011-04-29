class Seminar < ActiveRecord::Base
  # Lectureable que representa um objeto multimídia simples, podendo ser aúdio,
  # vídeo ou mídia externa (e.g youtube).

  # Utilizado na validação
  #FIXME mover par arquivos de configuração
  SUPPORTED_VIDEOS = [ 'application/x-mp4',
    'video/x-flv',
    'application/x-flv',
    'video/mpeg',
    'video/quicktime',
    'video/x-la-asf',
    'video/x-ms-asf',
    'video/x-msvideo',
    'video/x-sgi-movie',
    'video/x-flv',
    'flv-application/octet-stream',
    'video/3gpp',
    'video/3gpp2',
    'video/3gpp-tt',
    'video/BMPEG',
    'video/BT656',
    'video/CelB',
    'video/DV',
    'video/H261',
    'video/H263',
    'video/H263-1998',
    'video/H263-2000',
    'video/H264',
    'video/JPEG',
    'video/MJ2',
    'video/MP1S',
    'video/MP2P',
    'video/MP2T',
    'video/mp4',
    'video/MP4V-ES',
    'video/MPV',
    'video/mpeg4',
    'video/mpeg',
    'video/avi',
    'video/mpeg4-generic',
    'video/nv',
    'video/vnd.objectvideo',
    'video/parityfec',
    'video/pointer',
    'video/raw',
    'video/rtx' ]

  SUPPORTED_AUDIO = ['audio/mpeg', 'audio/mp3']

  # Video convertido
  has_attached_file :media, VIDEO_TRANSCODED
  # Video original. Mantido para caso seja necessário refazer o transcoding
  has_attached_file :original, {}.merge(VIDEO_ORIGINAL)

  # Callbacks
  # Se for tipo upload, chama o metodo define_content_type
  before_validation :enable_correct_validation_group
  before_create :truncate_youtube_url

  has_one :lecture, :as => :lectureable

  # Maquina de estados do processo de conversão
  acts_as_state_machine :initial => :waiting, :column => 'state'

  state :waiting
  state :converting, :enter => :transcode
  state :converted
  state :failed

  event :convert do
    transitions :from => :waiting, :to => :converting
  end

  event :ready do
    transitions :from => :converting, :to => :converted
    transitions :from => :waiting, :to => :converted
  end

  event :fail do
    transitions :from => :converting, :to => :failed
  end

  # Validations Groups - Habilitar diferentes validacoes dependendo do tipo.
  validation_group :external,
    :fields => [:external_resource, :external_resource_type]
  validation_group :uploaded, :fields => [:original]

  validates_presence_of :external_resource, :external_resource_type
  validates_attachment_presence :original
  validate :accepted_content_type
  validates_attachment_size :original,
    :less_than => 100.megabytes

  def import_redu_seminar(url)
    lecture_id = url.scan(/aulas\/([0-9]*)/)

    unless lecture_id.empty?
      @source = Lecture.find(lecture_id[0][0])
      # copia (se upload ou youtube)
      @source.is_clone = true #TODO evitar que sejam removido
    end

    if @source
      if @source.lectureable_type == 'Seminar'
        if @source.lectureable.external_resource_type.eql?('youtube')
          self.external_resource_type = 'youtube'
          self.external_resource = 'http://www.youtube.com/watch?v=' + @source.lectureable.external_resource
          return [true, ""]
        elsif @source.lectureable.external_resource_type.eql?('upload')
          self.external_resource_type = 'upload' # melhor ficar 'redu'?
          self.media_file_name = @source.lectureable.media_file_name
          self.media_content_type = @source.lectureable.media_content_type
          self.media_file_size = @source.lectureable.media_file_size
          self.media_updated_at = @source.lectureable.media_updated_at
          return [true, ""]
        end

      else
        return [false, "Aula não é um seminário"]
      end
    else
      return [false, "Link não válido ou aula não pública"]
    end

  end

  def validate_youtube_url
    if self.valid? and external_resource_type.eql?('youtube')
      capture = external_resource.scan(/youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/)[0]
      errors.add(:external_resource, "Link inválido") unless capture
    end
  end
  # Retorna parâmetro da URL que identifica unicamente o vídeo
  def truncate_youtube_url
      if self.external_resource_type.eql?('youtube')
        capture = self.external_resource.scan(/youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/)[0][0]
        # TODO criar validacao pra essa url
        self.external_resource = capture
      end
  end

  # Converte o video para FLV (Zencoder)
  def transcode
    seminar_info = {
      :id => self.id,
      :class => self.class.to_s.tableize,
      :attachment => 'medias',
      :style => 'original',
      :basename => self.original_file_name.split('.')[0],
      :extension => 'flv'
    }

    output_path = "s3://" + VIDEO_TRANSCODED[:bucket] + "/" + interpolate(VIDEO_TRANSCODED[:path], seminar_info)

    ZENCODER_CONFIG[:input] = self.original.url
    ZENCODER_CONFIG[:output][:url] = output_path
    ZENCODER_CONFIG[:output][:thumbnails][:base_url] = File.dirname(output_path)
    ZENCODER_CONFIG[:output][:notifications][:url] = "http://#{ZENCODER_CREDENTIALS[:username]}:#{ZENCODER_CREDENTIALS[:password]}@beta.redu.com.br/jobs/notify"

    response = Zencoder::Job.create(ZENCODER_CONFIG)
    puts response.inspect
    if response.success?
      self.job = response.body["id"]
    else
      self.fail!
    end
  end

  def video?
    SUPPORTED_VIDEOS.include?(self.original_content_type)
  end

  def audio?
    SUPPORTED_AUDIO.include?(self.original_content_type)
  end

  # Decide qual validation_group será habilitado
  def enable_correct_validation_group
    if self.external_resource_type != "upload"
      self.enable_validation_group :external
    else
      self.enable_validation_group :uploaded
      self.define_content_type
    end
  end

  def type
    if video?
      self.original_content_type
    else
      self.external_resource_type
    end
  end

  def need_transcoding?
    self.video? or self.audio?
  end

  # Verifica se o curso tem espaço suficiente para o arquivo
  def can_upload_multimedia?(lecture)
    return true if self.external_resource_type == "youtube"
    return false unless lecture.subject.space.course.plan.active?
    plan = lecture.subject.space.course.plan
    quota = lecture.subject.space.course.quota
    if quota.multimedia > plan.video_storage_limit
      return false
    else
      return true
    end
  end

  protected
  # Deriva o content type olhando diretamente para o arquivo. Workaround para
  # problemas decorrentes da integração uploadify/rails
  # http://github.com/alainbloch/uploadify_rails
  # Deve ser chamado antes de salvar
  def define_content_type
    self.original_content_type = MIME::Types.type_for(self.original_file_name).to_s
  end

  def interpolate(text, mapping)
    mapping.each do |k,v|
      text = text.gsub(':'.concat(k.to_s), v.to_s)
    end
    return text
  end

  # Workaround: Valida content type setado pelo método define_content_type
  def accepted_content_type
    self.errors.add(:original, "Formato inválido") unless video? or audio?
  end
end
